<div class="album py-5 bg-light">
    <div class="container">
        <h1>Position</h1>
        <hr>
        <br />

        <?php if(isset($nbrUpdate)) { ?>
            <div class="alert alert-success" role="alert">
                <?php echo $nbrUpdate; ?> positions d'avions récupérées
            </div>
        <?php } ?>
        <?php if(isset($error_msg)) { ?>
            <div class="alert alert-danger" role="alert">
                <?php echo $error_msg; ?> 
            </div>
        <?php } ?>

        <h4>Mettre à jour la position</h4>
        <p>
            Il est possible de récupérer la position des avions dans une zone précise.
        </p>
        <?php 
        for ($j=0; $j <= 7; ++$j) { 
            for ($i=0; $i <= 7; ++$i) { 
                echo '<a href="?update=True&x=' . $i .'&y=' . $j . '">';
                echo '<img src="' . url_image('/monde/monde_' . $i . $j . '.png') . '" style="width: 12%;padding: 0.25%;border: 1px solid gray;">';
                echo '</a>';
            }
            echo '<br />';
        } ?>
        <br />
        <br />

        <h4>Positions des avions actuellement dans la base de donnée:</h4>

        <div class="alert alert-info" role="alert">
            Certaines entrées ont une date postérieure à l'heure actuelle.  Un ticket a été ouvert auprès de "Laminar Data".
        </div>

        <table class="table table-hover table-bordered">
            <thead>
                <tr>
                  <th scope="col">ID</th>
                  <th scope="col">Companie</th>
                  <th scope="col">Dernière position</th>
                  <th scope="col">Dernière update</th>
                </tr>
            </thead>
            <tbody>
                <?php 
                foreach ($allPlanePosition as $avion) {
                    echo '<tr>';
                    echo '<td>' . $avion['planeid'] . '</td>';
                    echo '<td>' . $avion['company'] . '</td>';
                    echo '<td>' . $avion['last_position'] . '</td>';
                    echo '<td>' . $avion['last_update'] . '</td>';
                    echo '</tr>';
                } ?>
            </tbody>
        </table>

        <!--<script>
        function allInitMap() {
            <?php //foreach ($listUpdate as $indexToUpdate) {
                //echo 'initMap' . $indexToUpdate . '();';
            // } ?>
        }
        </script>
        <script async defer
            src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBgQt1WwFNWT1oxWouEFWzHkeQtb8vdrYE&callback=allInitMap">
        </script>-->

    </div>
</div>
