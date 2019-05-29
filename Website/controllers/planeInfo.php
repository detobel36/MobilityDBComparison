<?php
require_once('useful.php');

loadModel('Model_all_plane');

echo '<pre>';
print_r(get_plane_info('003021df-cf0e-451f-9d5b-178fc2bf6d1a'));
echo '</pre>';
