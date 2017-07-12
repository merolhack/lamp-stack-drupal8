# README #

Scripts en bash para realizar instalación y mantenimiento de Drupal y su ambiente.

### Descripción de los scripts ###

* 1.- Instalar ambiente LAMP Stack:

    $ ~/scripts/install-lamp-stack.sh

* 2.- Establecer permisos iniciales e instalar firewalld:

    $ ~/scripts/perform-initial-security.sh

* 3.- Instalar mediante composer Drupal 8:

    $ ~/scripts/install-drupal.sh

* 4.- Instalar los subsitios:

    $ ~/scripts/make-multisites.sh

* 5 .- Habilitar módulos del Core e instalar los módulos adicionales:

    $ ~/scripts/install-drupal-modules.sh

### CRLF de Windows a LF de Unix ###

    sed 's/\r//' ~/scripts/script.sh > ~/scripts/script.tmp && mv ~/scripts/script.tmp ~/scripts/script.sh

### Cambiar a modo ejecutable ###

    chmod +x ~/scripts/script.sh

### Ejecutar script ###

    ~/scripts/script.sh
