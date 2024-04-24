#!/bin/bash



# Vérifier si un nom de projet a été fourni
if [ -z "$1" ]; then
  echo "Veuillez fournir un nom de projet."
  exit 1
fi

# Créer un dossier pour le projet et se déplacer dedans
mkdir "$1"
cd "$1"

# Initialiser un projet Composer
composer init

# Ajouter les dépendances nécessaires avec Composer
composer require slim/slim:"4.*"
composer require slim/psr7 -W
composer require nyholm/psr7
composer require nyholm/psr7-server
composer require guzzlehttp/psr7 "^2"
composer require laminas/laminas-diactoros
composer require slim/php-view

# Créer la structure de dossiers
mkdir public
mkdir routes
mkdir views
mkdir -p src/Controllers
mkdir -p src/Models

# Créer le fichier public/index.php
cat <<EOF >public/index.php
<?php
// Indiquer les classes à utiliser
use Slim\Factory\AppFactory;
// Activer le chargement automatique des classes
require __DIR__ . '/../vendor/autoload.php';
// Créer l'application
\$app = AppFactory::create();
// Ajouter certains traitements d'erreurs
\$app->addErrorMiddleware(true, true, true);
// Définir les routes
require __DIR__ . '/../routes/web.php';
// Lancer l'application
\$app->run();
EOF

# Créer le fichier routes/web.php
cat <<EOF >routes/web.php
<?php
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

use Matteomcr\\$1\Controllers\HomeController;


\$app->get('/', [HomeController::class, 'showHomePage']);
EOF

# Créer le fichier public/.htaccess
cat <<EOF >public/.htaccess
Options All -Indexes
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^ index.php [QSA,L]
</IfModule>
EOF



# Création du fichier Database.php
cat <<EOF >src/Models/Database.php 
<?php

namespace Matteomcr\\$1\Models;
require_once "constantes.php";

use PDO;

class Database
{
    public static function connection(): PDO
    {
        static \$pdo = null;

        if (\$pdo === null) {
            try {
                \$dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=' . DB_CHARSET;

                \$options = [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ];

                \$pdo = new PDO(\$dsn, DB_USER, DB_PASS, \$options);
            } catch (\\Throwable \$th) {
                // @todo Add log entry
                die("Can't connect to database");
            }
        }

        return \$pdo; 
    }
}
EOF

# Création du fichier constantes.php
cat <<EOF >src/Models/constantes.php 
<?php
    define('DB_HOST', 'localhost');
    define('DB_NAME', 'Spectacle');
    define('DB_USER', 'root');
    define('DB_PASS', 'Super');
    define('DB_CHARSET', 'utf8mb4');

?>

EOF


# Création du fichier BaseController.php
cat <<EOF >src/Controllers/BaseController.php 
<?php

namespace Matteomcr\\$1\\Controllers;

use Slim\Views\PhpRenderer;

abstract class BaseController
{
    protected PhpRenderer \$view;

    function __construct(){
        \$this->view = new PhpRenderer(__DIR__ .'/../../views', [
            'title' => 'Slimages',
        ]);

    }
}
EOF

# Création du fichier HomeController.php
cat <<EOF >src/Controllers/HomeController.php 
<?php

namespace Matteomcr\\$1\Controllers;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;




class HomeController extends BaseController{

    public function showHomePage(ServerRequestInterface \$request, ResponseInterface \$response, array \$args) : ResponseInterface{
        
        return \$this->view->render(\$response, 'homepage.php');
    }
   
}

EOF

# Création du fichier HomeController.php
cat <<EOF >src/Models/Utilisateur.php 
<?php

namespace Matteomcr\\$1\Models;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Matteomcr\\$1\Models\Database;


class Utilisateur{
    public \$idUtilisateur;
    public \$email;
    public \$motDePasse;
    public \$prenom;
    public \$nom;
    public \$dateDeNaissance;
    public \$idRole;
    protected \$role = null;
    

    public static function fetchAll() :array
    {
        \$statement = Database::connection()->prepare("SELECT * FROM UTILISATEUR");
        \$statement->execute();
        \$statement->setFetchMode(\PDO::FETCH_CLASS | \PDO::FETCH_PROPS_LATE, static::class);
        return \$statement->fetchAll();
    }

    public static function fetchByEmail(string \$email) : Utilisateur|false
    {
        \$statement = Database::connection()
        ->prepare("SELECT * FROM UTILISATEUR WHERE email = :email");
        \$statement->execute([':email' => \$email]);
        \$statement->setFetchMode(\PDO::FETCH_CLASS | \PDO::FETCH_PROPS_LATE, static::class);
        return \$statement->fetch();
    }

    s

}


EOF


# Création du fichier homepage.php
cat <<EOF >views/homepage.php 
<h2>Vous êtes bien sur la page d'accueil !</h2>
<?php
echo "W";

EOF

cd public
php -S localhost:8080

echo "Projet $1 créé avec succès."
