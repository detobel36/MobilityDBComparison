<html>
<head>
    <title>Visual County</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" />
    <style>
        #map {
            position: absolute;
            top: 0;
            left: 0;
            bottom: 0;
            right: 0;
        }

        .info {
            padding: 6px 8px;
            font: 14px/16px Arial, Helvetica, sans-serif;
            background: white;
            background: rgba(255,255,255,0.8);
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
            border-radius: 5px;
        }
        
        .info h4 {
            margin: 0 0 5px;
            color: #777;
        }
    </style>
</head>
<body>
    <div id="map"></div>

    <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js"></script>
    <script src="./assets/js/leaflet-realtime.min.js"></script>
    <script src="./assets/js/visualCounty.js"></script>
</body>
</html>
