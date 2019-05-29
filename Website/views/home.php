<section class="jumbotron text-center">
    <div class="container">
        <h1 class="jumbotron-heading">Position des bus de New York</h1>
        <p class="lead text-muted">
            Cette page reprend les différentes interfaces permettant de visualiser ou de donner des informations sur l'API mis en place par MTA (la société de transport en commun de la ville de New York).
        </p>
<!--         <p>
            <a href="#" class="btn btn-primary my-2">Main call to action</a>
            <a href="#" class="btn btn-secondary my-2">Secondary action</a>
        </p> -->
    </div>
</section>

<div class="album py-5 bg-light">
    <div class="container">
        <div class="row">

            <div class="card" style="width: 18rem;margin: auto;">
                <div class="card-body">
                    <h5 class="card-title">Résumé</h5>
                    <p class="card-text">
                        Page résumant et expliquant les donnes récupérées
                    </p>
                    <a href="<?php echo base_url('resume'); ?>" class="btn btn-primary">Résumé</a>
                </div>
            </div>
            <!-- <div class="card" style="width: 18rem;margin: auto;">
                <div class="card-body">
                    <h5 class="card-title">Position</h5>
                    <p class="card-text">
                        Permet de récupérer les avions dans une zone particulière
                    </p>
                    <a href="<?php echo base_url('position'); ?>" class="btn btn-primary">Position</a>
                </div>
            </div> -->
            <div class="card" style="width: 18rem;margin: auto;">
                <div class="card-body">
                    <h5 class="card-title">Carte</h5>
                    <p class="card-text">
                        Permet d'afficher la position des bus et leur ligne
                    </p>
                    <a href="<?php echo base_url('map'); ?>" class="btn btn-primary">Carte</a>
                </div>
            </div>
        </div>
    </div>
</div>