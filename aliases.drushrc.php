<?php
/**
* @file
* Site alias for all sites
*/
$root = '/var/www/html';

$aliases['mazatlan'] = array(
  'uri' => 'unam.local/mazatlan',
  'root' => $root,
  'path-aliases' => array(
    '%dump-dir' => $root . '/private/mazatlan/tmp'
  ),
);
$aliases['puerto_morelos'] = array(
  'uri' => 'unam.local/puerto_morelos',
  'root' => $root,
  'path-aliases' => array(
    '%dump-dir' => $root . '/private/puerto_morelos/tmp'
  ),
);
$aliases['el_carmen'] = array(
  'uri' => 'unam.local/el_carmen',
  'root' => $root,
  'path-aliases' => array(
    '%dump-dir' => $root . '/private/el_carmen/tmp'
  ),
);
$aliases['uves'] = array(
  'uri' => 'unam.local/uves',
  'root' => $root,
  'path-aliases' => array(
    '%dump-dir' => $root . '/private/uves/tmp'
  ),
);
$aliases['cu_biodiversidad'] = array(
  'uri' => 'unam.local/cu_biodiversidad',
  'root' => $root,
  'path-aliases' => array(
    '%dump-dir' => $root . '/private/cu_biodiversidad/tmp'
  ),
);
$aliases['cu_clima'] = array(
  'uri' => 'unam.local/cu_clima',
  'root' => $root,
  'path-aliases' => array(
    '%dump-dir' => $root . '/private/cu_clima/tmp'
  ),
);