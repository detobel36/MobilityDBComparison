<?php

$random= rand(0, 2);
if($random == 0) {
    echo '{"geometry": {"type": "Point", "coordinates": [-144.56201880774935, -42.88078791898701]}, "type": "Feature", "properties": {}}';
} else if($random == 1) {
    echo '{"geometry": {"type": "Point", "coordinates": [-52.25402059253551, 37.86452147517722]}, "type": "Feature", "properties": {}}';
} else if($random == 2) {
    echo '{"geometry": {"type": "Point", "coordinates": [0.5739244232270739, 49.998536047806326]}, "type": "Feature", "properties": {}}';
}

?>