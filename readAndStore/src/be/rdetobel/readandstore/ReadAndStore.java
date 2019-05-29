package be.rdetobel.readandstore;

import com.google.transit.realtime.GtfsRealtime;
import java.io.File;
import com.google.transit.realtime.GtfsRealtime.FeedMessage;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

/**
 *
 * @author remy
 */
public class ReadAndStore {
    
    private static final Logger logger = Logger.getLogger(ReadAndStore.class.getName());
    private static final Pattern pattern = Pattern.compile("\\:([0-9a-zA-Z\\_\\-\\.])+ ");
    
    private static Properties databaseProperties = new Properties();
    private static final String pathDatabaseProperties = "config.properties";
    private static final String requestPath = "request.sql";
    private static ArrayList<String> listRequest;
    
    private static HashMap<String, Long> timeDiff = new HashMap<String, Long>();
    
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        final String folder = "data";
        final File dataFolder = new File(folder);
        
        readDatabaseConfig();
        loadRequest();
        
        final PostgresPublisher postgresSource = new PostgresPublisher(
                databaseProperties.getProperty("host"), 
                Integer.parseInt(databaseProperties.getProperty("port")), 
                databaseProperties.getProperty("name"), 
                databaseProperties.getProperty("user"), 
                databaseProperties.getProperty("password"));
        logger.info("Open PostgresSource");
        if(!postgresSource.open()) {
            logger.info("Arret: Erreur BDD");
            return;
        }
        
        final File[] listFile = dataFolder.listFiles();
        final ArrayList<String> strListFile = new ArrayList<String>();
        final HashMap<String, File> listFichier = new HashMap<String, File>();
        
        for(final File fichier : listFile) {
            final String name = fichier.getName();
            strListFile.add(name);
            listFichier.put(name, fichier);
        }
        Collections.sort(strListFile);
        logger.log(Level.INFO, "Ordre des fichiers: {0}", Arrays.toString(strListFile.toArray()));
        int totalEntity = 0;
        
        for(final String strFichier : strListFile) {
            final File fichier = listFichier.get(strFichier);
            logger.log(Level.INFO, "Ouverture du fichier: {0}", strFichier);
            
            try {
                final InputStream is = new FileInputStream(fichier);
                int nbrEntity = 0;
                
                Long lastUpdate = System.currentTimeMillis();
                long lastEntityTimestamp = 0l;
                while(is.available() > 0) {
                    final FeedMessage feed = FeedMessage.parseDelimitedFrom(is);
                    
                    for(final GtfsRealtime.FeedEntity entity : feed.getEntityList()) {
                        if(entity.hasVehicle()) {
                            final GtfsRealtime.VehiclePosition vehicle = entity.getVehicle();

                            final HashMap<String, String> allInformations = new HashMap<String, String>();
                            
                            if(vehicle.hasVehicle() && vehicle.getVehicle().hasId()) {
                                allInformations.put("id", vehicle.getVehicle().getId());
                            }
                            
                            if(vehicle.hasTrip()) {
                                final GtfsRealtime.TripDescriptor trip = vehicle.getTrip();
                                if(trip.hasTripId()) {
                                    allInformations.put("trip_id", trip.getTripId()); 
                                }
                                if(trip.hasStartDate()) {
                                    allInformations.put("start_date", trip.getStartDate());  // Format AAAAMMJJ
                                }
                                if(trip.hasRouteId()) {
                                    allInformations.put("route_id", trip.getRouteId());
                                }
                                if(trip.hasDirectionId()) {
                                    allInformations.put("direction_id", "" + trip.getDirectionId());
                                }
                            }
                            if(vehicle.hasPosition()) {
                                allInformations.put("point", 
                                        "POINT(" + vehicle.getPosition().getLongitude() + 
                                            " " + vehicle.getPosition().getLatitude() + ")");

                                if(vehicle.getPosition().hasBearing()) {
                                    allInformations.put("bearing", "" + vehicle.getPosition().getBearing());
                                }
                            }
                            if(vehicle.hasTimestamp()) {
                                lastEntityTimestamp = vehicle.getTimestamp();
                                allInformations.put("time", "" + lastEntityTimestamp);
                            }
                            
                            if(vehicle.hasTimestamp() && vehicle.hasVehicle() && vehicle.getVehicle().hasId()) {
                                final String vehicleId = vehicle.getVehicle().getId();
                                if(timeDiff.containsKey(vehicleId)) {
                                    allInformations.put("timeDiff", "" + (lastEntityTimestamp-timeDiff.get(vehicleId)));
                                } else {
                                    allInformations.put("timeDiff", "" + 0);
                                }
                                timeDiff.put(vehicleId, lastEntityTimestamp);
                            }
                            
                            if(vehicle.hasStopId()) {
                                allInformations.put("stop_id", "" + vehicle.getStopId());
                            }

                            listRequest.stream().map((request) ->
                                    addValueToQuery(allInformations, request))
                                    .forEach((newRequest) -> {
                                try {
                                    postgresSource.execute(newRequest);
                                } catch (SQLException | ClassNotFoundException ex) {
                                    logger.info("Request: " + newRequest);
                                    logger.log(Level.SEVERE, null, ex);
                                }
                            }); 
                            

                            ++nbrEntity;
                            ++totalEntity;
                            if(System.currentTimeMillis()-lastUpdate > 30000) {
                                logger.log(Level.INFO, "NbrEntity: {0} - Last update time: {1}", 
                                        new Object[]{nbrEntity, lastEntityTimestamp});
                                lastUpdate = System.currentTimeMillis();
                            }
                        }
                    }
                }
                logger.log(Level.INFO, "Fetch {0}", new Object[]{nbrEntity});
                
            } catch (IOException ex) {
                logger.log(Level.SEVERE, null, ex);
            }
            
        }
        logger.log(Level.INFO, "Total Entity: {0}", totalEntity);
    }
    
    
    
    private static String addValueToQuery(final HashMap<String, String> pointInfos, String query) {
        for(final Map.Entry<String, String> infos : pointInfos.entrySet()) {
            String value = infos.getValue();
            if(infos.getKey().equalsIgnoreCase("time")) {
                value = ""+ Long.parseLong(value);
            }
            query = query.replaceAll(":" + infos.getKey() + " ", value);
        }
        
        if(pattern.matcher(query).find()) {
            logger.log(Level.INFO, "Requete ignor\u00e9 car des valeurs n''ont "
                    + "pas pu \u00eatre remplac\u00e9e: ''{0}''", query);
            logger.log(Level.INFO, "Infos: {0}", pointInfos.keySet());
            return "";
        }
        
        return query;
    }
    
    private static boolean readDatabaseConfig() {
        try {
            logger.info("read database properties from file " + pathDatabaseProperties);
            databaseProperties.load(new FileInputStream(pathDatabaseProperties));
        } catch (FileNotFoundException e) {
            logger.severe("file " + pathDatabaseProperties + " not found");
            System.exit(1);
            return false;
        } catch (IOException e) {
            logger.log(Level.SEVERE,"reading database properties from file " + 
                    pathDatabaseProperties + " failed: {0}", e.getMessage());
            System.exit(1);
            return false;
        }
        return true;
    }
    
    private static void loadRequest() {
        // Stock the request + true if we need to wait some result
        listRequest = new ArrayList<String>();
        // Variable temporaire
        String currentStr = "";
        
        try (BufferedReader br = Files.newBufferedReader(Paths.get(requestPath))) {
            // read line by line
            String line;
            while ((line = br.readLine()) != null) {
                final int indexBrace = line.indexOf(";");
                if(indexBrace != -1) {
                    currentStr += line.substring(0, indexBrace+1);
                    if(!currentStr.trim().equalsIgnoreCase("")) {
                        listRequest.add(currentStr);
                    }
                    currentStr = line.substring(indexBrace+1) + " ";
                    
                } else {
                    currentStr += line + " ";
                }
            }
            if(!currentStr.trim().equalsIgnoreCase("")) {
                listRequest.add(currentStr);
            }
            
            logger.info("Loaded request: ");
            listRequest.forEach((request) -> {
                logger.log(Level.INFO, "> {0}", request);
            });
            logger.info("----");
            
        } catch (IOException e) {
            logger.log(Level.SEVERE, null, e);
        }
    }
    
}
