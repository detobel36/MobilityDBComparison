<!doctype html>
<html lang="fr">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="description" content="Page d'information sur la position des bus dans la ville de New York">
        <meta name="author" content="Detobel">
        <!--<link rel="icon" href="../../../../favicon.ico">-->

        <title>MTA New York</title>

        <!-- Bootstrap core CSS -->
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" rel="stylesheet">

        <!-- Custom styles for this template -->
        <link href="./assets/css/album.css" rel="stylesheet">
        <link href="./assets/css/custom.css" rel="stylesheet">
    </head>

  <body>

    <header>
        <div class="navbar navbar-dark bg-dark shadow-sm">
            <div class="container d-flex justify-content-between">
                <a href="<?php echo base_url(); ?>" class="navbar-brand d-flex align-items-center">
                    <strong>MTA New York</strong>
                </a>
                <nav class="nav nav-masthead justify-content-center">
                    <a class="nav-link <?php if(current_url() == base_url('resume')) { echo 'active'; } ?>" 
                            href="<?php echo base_url('resume'); ?>">
                        Résumé
                    </a>
                    <a class="nav-link <?php if(current_url() == base_url('viewPointsCustom')) { echo 'active'; } ?>" 
                            href="<?php echo base_url('viewPointsCustom'); ?>">
                        Positions
                    </a>
                    <a class="nav-link <?php if(current_url() == base_url('map')) { echo 'active'; } ?>" 
                            href="<?php echo base_url('map'); ?>">
                        Carte
                    </a>
                    <a class="nav-link" target="_blank" href="http://web.mta.info/developers/">
                        MTA Developers
                        <span data-feather="external-link"></span>
                    </a>
                </nav>
            </div>
        </div>
    </header>


    <main role="main">
