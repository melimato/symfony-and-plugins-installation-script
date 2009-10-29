#!/bin/bash

#-------------------------------------------------------------------------------
## FUNCTIONS
#-------------------------------------------------------------------------------
usage()
{
    cat << EOF
usage: $0 OPTION...

This script attempts to install Symfony according to pre-configured settings and with sfDoctrinePlugin.

OPTIONS:
   -h, --help           Show this message
   -c, --config-file    Specify config file to use
   -l, --language       Specify optional language support (Using MySQL i18n)
   -i, --install-plugin Specify optional plugins to install. Currently supported plugins are:
                            * sfDoctrineGuardPlugin : sfGuard for doctrine...
                            * sfDoctrineGuardExtraPlugin : Add forgot password and register functionality to sfGuard
                            * sfAdminDashPlugin : Adds Joomla! style admin dashboard interface
                            * csDoctrineActAsSortablePlugin : Adds Sortable behaviour
                            * csDoctrineActAsAttachablePlugin : Adds Attachable behaviour
                            * sfDoctrineActAsTaggablePlugin : Adds tag behaviour
                            * csDoctrineActAsCategorizablePlugin : Permits to assign nested categories do doctrine models
                            * sfDoctrineActAsRattablePlugin : This plugin permits to attach rates to Doctrine objects
                            * sfEventCalendarPlugin : Wrapper around data_calc pear class to manage event calendars
                            * sfJqueryReloadedPlugin : Adds easy jquery
                            * pkContextCMSPlugin : Fully working CMS with in place editing
                            * pkToolkitPlugin : is a collection of useful classes implementing common routines and algorithms we otherwise find ourselves reinventing in nearly every application.
                            * pkPersistentFileUploadPlugin : File uploads that persist automatically through multiple validation passes.
                            * pkImageConverterPlugin : Easy, efficient image conversion using the netpbm utilities.
                            * sfLanguageSwitchPlugin: A component to include a simple language switcher.

                            * [Under Development] csSEOToolkitPlugin : Provides several tools to optimize websites for search engines
                            * [Under Development] sfDoctrineManagerPlugin : Offers the ability to control Doctrine related functionality from a web based interface
                            * [Under Development] sfLinkCrossAppPlugin : Resolve link cross application in Symfony
                            * [Under Development] SomeMinifyPlugin :
                            * [Under Development] sfDoctrineApplyPlugin :

EOF
    exit 1
}

installPlugins()
{
    for PLUGIN in $PLUGINS_TO_INSTALL; do
        case "$PLUGIN" in
            sfDoctrineGuardPlugin) sfDoctrineGuardPlugin;  ;;
            sfDoctrineGuardExtraPlugin) sfDoctrineGuardExtraPlugin;  ;;
            sfAdminDashPlugin) sfAdminDashPlugin;  ;;
            csDoctrineActAsSortablePlugin) csDoctrineActAsSortablePlugin;  ;;
            sfDoctrineActAsTaggablePlugin) sfDoctrineActAsTaggablePlugin;  ;;
            csDoctrineActAsCategorizablePlugin) csDoctrineActAsCategorizablePlugin;  ;;
            sfDoctrineActAsRattablePlugin) sfDoctrineActAsRattablePlugin;  ;;
            sfEventCalendarPlugin) sfEventCalendarPlugin;  ;;
            pkContextCMSPlugin) pkContextCMSPlugin;  ;;
            pkToolkitPlugin) pkToolkitPlugin;  ;;
            pkPersistentFileUploadPlugin) pkPersistentFileUploadPlugin;  ;;
            pkImageConverterPlugin) pkImageConverterPlugin;  ;;
            sfLanguageSwitchPlugin) sfLanguageSwitchPlugin;  ;;

            csSEOToolkitPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL csSEOToolkitPlugin";  ;;
            sfDoctrineManagerPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfDoctrineManagerPlugin";  ;;
            sfLinkCrossAppPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfLinkCrossAppPlugin";  ;;
            SomeMinifyPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL SomeMinifyPlugin";  ;;
            sfDoctrineApplyPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfDoctrineApplyPlugin";  ;;
        esac
    done
}

clearCache()
{
    echo $FUNCNAME
    rm -rf cache/*
}

askDeleteAll()
{
    # remove existing files
    echo "Delete everything in dir ($(pwd))? [y]"
    read ANS
    if [ "$ANS" != 'n' ]; then
        echo Deleting...
        sudo rm -rf *
        echo Done.
    fi
}

askOpenMysqlTerminal()
{
    echo "Open new terminal with mysql? [y]"
    read ANS
    if [ "$ANS" != 'n' ]; then
        gnome-terminal --tab --tab -x bash -c "mysql -u$DB_USER -p$DB_PASS $DB_NAME -e 'show tables'; mysql -u$DB_USER -p$DB_PASS $DB_NAME; bash"
    fi
}

askOpenFirefox()
{
    # Open firefox with 2 tabs (front & back)
    echo "Open firefox with both applications ($BACKEND_APP_NAME, $FRONTEND_APP_NAME)? [y]"
    read ANS
    if [ "$ANS" != 'n' ]; then
        firefox http://$LOCALHOST_NAME/$BACKEND_APP_NAME/${BACKEND_APP_NAME}_dev.php http://$LOCALHOST_NAME/${FRONTEND_APP_NAME}_dev.php
    fi
}

downloadSf()
{
    if ! [ -f $TGZ_DIR/symfony-${SYMFONY_VERSION}.tgz ]; then
        wget http://www.symfony-project.org/get/symfony-${SYMFONY_VERSION}.tgz -O $TGZ_DIR/symfony-${SYMFONY_VERSION}.tgz
    fi
}

installSf()
{
    mkdir -p $SYMFONY_DIR
    if [ -f $TGZ_DIR/symfony-${SYMFONY_VERSION}.tgz ]; then
        echo "Uncompressing $TGZ_DIR/symfony-${SYMFONY_VERSION}.tgz"
        tar zxf $TGZ_DIR/symfony-${SYMFONY_VERSION}.tgz
        mv symfony-${SYMFONY_VERSION}/lib $SYMFONY_DIR/${SYMFONY_TAG}_lib
        mv symfony-${SYMFONY_VERSION}/data $SYMFONY_DIR/${SYMFONY_TAG}_data
        rm -rf symfony-${SYMFONY_VERSION}
        echo Done.
    fi

    # Try n' get it from svn if no symfony tgz was specified
    if ! [ -d $SYMFONY_DIR/${SYMFONY_TAG}_lib ]; then
        svn export http://svn.symfony-project.com/tags/${SYMFONY_TAG}/lib $SYMFONY_DIR/${SYMFONY_TAG}_lib;
    fi
    if ! [ -d $SYMFONY_DIR/${SYMFONY_TAG}_data ]; then
        svn export http://svn.symfony-project.com/tags/${SYMFONY_TAG}/data $SYMFONY_DIR/${SYMFONY_TAG}_data;
    fi

    ## make current links for fast switch
    if ! [ -L $SYMFONY_DIR/current_lib ]; then
        ln -s ${SYMFONY_TAG}_lib $SYMFONY_DIR/current_lib;
    fi
    if ! [ -L $SYMFONY_DIR/current_data ]; then
        ln -s ${SYMFONY_TAG}_data $SYMFONY_DIR/current_data;
    fi

    # only for build
    ln -s current_lib lib/vendor/symfony/lib;
    ln -s current_data lib/vendor/symfony/data;
}

customizeBackend()
{
    mkdir web/$BACKEND_APP_NAME
    mv web/$BACKEND_APP_NAME*.php web/$BACKEND_APP_NAME/
    sed -i -e "s/\.\./..\/../" web/$BACKEND_APP_NAME/$BACKEND_APP_NAME*.php
    cp web/.htaccess web/$BACKEND_APP_NAME/
    sed -e "s/'$FRONTEND_APP_NAME'/'$BACKEND_APP_NAME'/" -e "s/\.\./..\/../" web/index.php > web/$BACKEND_APP_NAME/index.php
    ln -s ../sf web/admin/sf
    ln -s ../sfProtoculousPlugin web/admin/sfProtoculousPlugin
    ln -s ../sfDoctrinePlugin web/admin/sfDoctrinePlugin
    ln -s ../uploads web/admin/uploads
}

setupApache()
{
    LOCALHOST_NAME="$PROJECT_NAME.lan"

    # Fix vhost
    sed -i -e '/NameVirtualHost\|Listen\|#/d' -i -e 's/127.0.0.1/*/' -i -e 's/localhost/lan/' config/vhost.sample
    sed -i -e "s/$SYMFONY_TAG/current/" config/vhost.sample

    echo "Apache's vhost file created in config/vhost.sample"
    if [ $(ls -l /etc/apache2/sites-enabled |grep -c "\<$LOCALHOST_NAME\>") -eq 0 ]; then
        echo "Copying Apache vhost file to /etc/apache2/sites-available/$LOCALHOST_NAME"
        sudo cp config/vhost.sample /etc/apache2/sites-available/$LOCALHOST_NAME
        echo "Enabling Apache vhost $LOCALHOST_NAME"
        sudo a2ensite $LOCALHOST_NAME
        echo "Restarting Apache gracefully"
        sudo apache2ctl graceful
    else
        echo "Vhost $LOCALHOST_NAME already anabled"
    fi
}

setupHostsFile()
{
    # Add host to /etc/hosts
    if [ $(grep -c "\<$LOCALHOST_NAME\>" /etc/hosts) -eq 0 ]; then
        echo "Adding $LOCALOST_NAME to /etc/hosts"
        sudo sed -i -e '$a\127.0.0.1 '"$LOCALHOST_NAME" /etc/hosts
    else
        echo "Hostname $LOCALHOST_NAME already in /etc/hosts"
    fi
}

fixSymfonyLn()
{
    # correct symfony lib
    echo "correct symfony lib"
    sed -i "3d"  config/ProjectConfiguration.class.php;
    sed -i "3irequire_once dirname(__FILE__).'/../lib/vendor/symfony/current_lib/autoload/sfCoreAutoload.class.php';" config/ProjectConfiguration.class.php
}

removePropel()
{
    echo "----------------------------------------"
    echo "--- Calling : $FUNCNAME"
    sed -i -e '2,6s/propel/doctrine/' -i -e '/propel/,/pooling:/d' config/databases.yml;
    rm web/sfPropelPlugin
    ln -s ../lib/vendor/symfony/current_lib/plugins/sfProtoculousPlugin/web web/sfProtoculousPlugin
    ln -s ../lib/vendor/symfony/current_data/web/sf web/sf
    ln -s ../lib/vendor/symfony/current_lib/plugins/sfDoctrinePlugin/web/ web/sfDoctrinePlugin
    rm config/schema.yml config/propel.ini

#    if [[ $(grep -c "^\/\/" config/ProjectConfiguration.class.php) -eq 0 ]]; then
#        # Change ProjectConfiguration to enable DOCTRINE and completely disable PROPEL.
#        sed -i -e "s/^\(.*enableAllPluginsExcept.*\)$/\/\/\1/" -i -e "/^\/\//a\    \$this->enablePlugins(array('sfDoctrinePlugin'));\n    \$this->disablePlugins(array('sfPropelPlugin'));" config/ProjectConfiguration.class.php
#    else
#        sed -i -e "s/\('sfDoctrinePlugin'\)/\1, '$1'/" config/ProjectConfiguration.class.php
#    fi
    sed -i -e "s/sfDoctrinePlugin/sfPropelPlugin/" config/ProjectConfiguration.class.php
    mkdir -p data/fixtures
    mkdir -p config/doctrine
}

upgradeDoctrine()
{
    echo "----------------------------------------"
    echo "--- Upgrading to $DOCTRINE_NAME $DOCTRINE_VER"
#    PLUGIN_NAME=Doctrine-$DOCTRINE_VER
#    if ! [ -f $TGZ_DIR/$PLUGIN_NAME.tgz ]; then
#        svn export http://svn.doctrine-project.org/branches/1.1/lib $TGZ_DIR/$PLUGIN_NAME
#        tar zcvf $TGZ_DIR/$PLUGIN_NAME.tgz -C $TGZ_DIR $PLUGIN_NAME/
#    fi
#    tar zxf $TGZ_DIR/$PLUGIN_NAME.tgz -C $DOCTRINE_DIR
    if ! [ -f $TGZ_DIR/${DOCTRINE_NAME}-${DOCTRINE_VER}.tgz ]; then
        echo wget http://www.doctrine-project.org/downloads/${DOCTRINE_NAME}-${DOCTRINE_VER}.tgz -O $TGZ_DIR/${DOCTRINE_NAME}-${DOCTRINE_VER}.tgz
        wget http://www.doctrine-project.org/downloads/${DOCTRINE_NAME}-${DOCTRINE_VER}.tgz -O $TGZ_DIR/${DOCTRINE_NAME}-${DOCTRINE_VER}.tgz
    fi

    DOCTRINE_DIR=lib/vendor/doctrine
    if [ -d $DOCTRINE_DIR ]; then
        rm -rf $DOCTRINE_DIR
    fi
    mkdir -p $DOCTRINE_DIR

    echo tar zxf $TGZ_DIR/${DOCTRINE_NAME}-${DOCTRINE_VER}.tgz -C /tmp/
    tar zxf $TGZ_DIR/${DOCTRINE_NAME}-${DOCTRINE_VER}.tgz -C /tmp/
    mv /tmp/${DOCTRINE_NAME}-${DOCTRINE_VER}/lib/* $DOCTRINE_DIR

    sed -i -e "/enableAllPluginsExcept/a\    sfConfig::set('sfDoctrinePlugin_doctrine_lib_path', sfConfig::get('sf_lib_dir') . '/vendor/doctrine/Doctrine.php');" config/ProjectConfiguration.class.php

    enablePlugin sfDoctrinePlugin
    php symfony doctrine:build-forms
    clearCache
}

enablePlugin()
{
    PLUGIN_NAME=$1
    echo "$FUNCNAME $PLUGIN_NAME"
    clearCache
}

publishAssets()
{
    # Publish assets
    echo "----------------------------------------"
    echo php symfony plugin:publish-assets
    php symfony plugin:publish-assets

    # "publish-assets" for BACKEND_APP_NAME directory
    if [ -L web/$PLUGIN_NAME ] && ! [ -L web/$BACKEND_APP_NAME/$PLUGIN_NAME ]; then
        ln -s ../$PLUGIN_NAME web/$BACKEND_APP_NAME/$PLUGIN_NAME
    fi
}

enableModule()
{
    _MODULE_NAME=$1
    _APP_NAME=$2
    if [[ -z $_MODULE_NAME ]] || [[ -z $_APP_NAME ]]; then
        echo "Missing params: Module Name: $_MODULE_NAME in Application Name: $_APP_NAME"
        exit 1
    fi

    _SETTINGS_FILE="apps/$_APP_NAME/config/settings.yml"

    # Only add if not alreay added
    if [ $(grep enabled_modules $_SETTINGS_FILE |grep -c "\<$_MODULE_NAME\>") -eq 0 ]; then

        # Enable first time
        sed -i -e "s/^#    enabled_modules:.*$/\    enabled_modules: [ default ]/" $_SETTINGS_FILE

        # Append it after default module  (always enabled)
        sed -i -e "s/^    \(enabled_modules: \[ default\)/\    \1, $_MODULE_NAME/" $_SETTINGS_FILE
    fi
}

configureDb()
{
    # database config
    echo "----------------------------------------"
    echo "Configuring database"
    # Create db and user if not exists
    mysql -u$DB_USER_SU -p$DB_PASS_SU -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    mysql -u$DB_USER_SU -p$DB_PASS_SU -e "GRANT ALL ON $DB_NAME.* to '$DB_USER'@localhost IDENTIFIED BY '$DB_PASS';"
    mysql -u$DB_USER_SU -p$DB_PASS_SU -e "FLUSH PRIVILEGES;"
    php symfony configure:database --name=doctrine --class=sfDoctrineDatabase "mysql:host=localhost;dbname=$DB_NAME" "$DB_USER" "$DB_PASS"
}

phpAccelerator()
{
    # Install PHP accelerator (Disabled for development)
    sed -i -e "s/^}$//" config/ProjectConfiguration.class.php
    echo "
  /**
   * Configure the Doctrine engine
   **/
  public function configureDoctrine(Doctrine_Manager \$manager)
  {
    //\$manager->setAttribute(Doctrine::ATTR_QUERY_CACHE, new Doctrine_Cache_Apc());
  }
}
" >> config/ProjectConfiguration.class.php
}

installZend()
{
    echo "----------------------------------------"
    echo "--- Installing ${ZEND_NAME} ${ZEND_VER}"
    if [ -d lib/vendor/Zend ]; then
        echo '!!! ALREADY INSTALLED'
        return 0
    fi
    if ! [ -f $TGZ_DIR/${ZEND_NAME}-${ZEND_VER}-minimal.tar.gz ]; then
        echo wget http://framework.zend.com/releases/${ZEND_NAME}-${ZEND_VER}/${ZEND_NAME}-${ZEND_VER}-minimal.tar.gz -O $TGZ_DIR/${ZEND_NAME}-${ZEND_VER}-minimal.tar.gz
        wget http://framework.zend.com/releases/${ZEND_NAME}-${ZEND_VER}/${ZEND_NAME}-${ZEND_VER}-minimal.tar.gz -O $TGZ_DIR/${ZEND_NAME}-${ZEND_VER}-minimal.tar.gz
    fi
    echo tar zxf $TGZ_DIR/${ZEND_NAME}-${ZEND_VER}-minimal.tar.gz -C /tmp/
    tar zxf $TGZ_DIR/${ZEND_NAME}-${ZEND_VER}-minimal.tar.gz -C /tmp/
    mv /tmp/${ZEND_NAME}-${ZEND_VER}-minimal/library/Zend lib/vendor/Zend
    sed -i -e "/enableAllPluginsExcept/a\    set_include_path(sfConfig::get('sf_lib_dir') . '/vendor' . PATH_SEPARATOR . get_include_path());\n" config/ProjectConfiguration.class.php
}

installPlugin()
{
    # Install plugin hack
    if [ -z $TGZ_DIR ]; then
        TGZ_DIR=/tmp
    fi

    PLUGIN_NAME=$1
    PLUGIN_VER=$2
    echo "----------------------------------------"
    echo "--- Installing $PLUGIN_NAME $PLUGIN_VER"
    if [ -d plugins/$PLUGIN_NAME ]; then
        echo '!!! ALREADY INSTALLED'
        return 0
    fi
    if ! [ -f $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}.tgz ]; then
        echo wget http://plugins.symfony-project.org/get/$PLUGIN_NAME/${PLUGIN_NAME}-${PLUGIN_VER}.tgz -O $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}.tgz
        wget http://plugins.symfony-project.org/get/$PLUGIN_NAME/${PLUGIN_NAME}-${PLUGIN_VER}.tgz -O $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}.tgz
    fi
    echo tar zxf $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}.tgz -C /tmp/
    tar zxf $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}.tgz -C /tmp/
    echo mv /tmp/${PLUGIN_NAME}-${PLUGIN_VER} plugins/$PLUGIN_NAME
    mv /tmp/${PLUGIN_NAME}-${PLUGIN_VER} plugins/$PLUGIN_NAME
}

svn2tgzPlugin()
{
    PLUGIN_NAME=$1
    PLUGIN_VER=$2
    PLUGIN_SVN=$3
    if ! [ -f $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}.tgz ]; then
        echo svn export $PLUGIN_SVN $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}
        svn export $PLUGIN_SVN $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}
        echo tar zcvf $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}.tgz -C $TGZ_DIR ${PLUGIN_NAME}-${PLUGIN_VER}/
        tar zcvf $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}.tgz -C $TGZ_DIR ${PLUGIN_NAME}-${PLUGIN_VER}/
        echo rm -rf $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}
        rm -rf $TGZ_DIR/${PLUGIN_NAME}-${PLUGIN_VER}
    fi
}

sfAdminDashPlugin()
{
    installPlugin $FUNCNAME 0.8.1

    # Include partials in application's layout
    sed -i -e "/sf_content/i\    <?php include_partial('sfAdminDash/header') ?>" -i -e "/sf_content/a\    <?php include_partial('sfAdminDash/footer') ?>" apps/$BACKEND_APP_NAME/templates/layout.php

    # Enable module & plugin
    enableModule sfAdminDash $BACKEND_APP_NAME
    enablePlugin $FUNCNAME

    # Change default homepage module
    sed -i -e "s/^  param: { module: default, action: index/  param: { module: sfAdminDash, action: dashboard/" apps/$BACKEND_APP_NAME/config/routing.yml

    # Create links for backend application
    ln -s ../sfAdminDashPlugin web/$BACKEND_APP_NAME/sfAdminDashPlugin

    # Preconfigure plugin
    sed -i -e "s/My Site/$PROJECT_NAME/" ./plugins/sfAdminDashPlugin/config/app.yml

    echo "
all:
  sf_admin_dash:
    categories:
#      Mailing Lists:
#        items:
#          Lists:
#            url:          some_url
#            credentials:  some_credential
#            image:        massemail.png
      Admin Users:
        credentials: admin
        items:
          Users:
            url:          sf_guard_user
            image:        users.png
            credentials:  admin
          Groups:
            url:          sf_guard_group
            image:        users.png
            credentials:  admin
          Permissions:
            url:          sf_guard_permission
            image:        users.png
            credentials:  admin
" >> apps/$BACKEND_APP_NAME/config/app.yml
}

sfDoctrineGuardPlugin()
{
    installPlugin $FUNCNAME 3.0.0
    enablePlugin $FUNCNAME

    # Load default fixtures
    cp plugins/sfDoctrineGuardPlugin/data/fixtures/fixtures.yml.sample data/fixtures/sfGuard.yml
    php symfony doctrine:data-load

    # Enable all sfGuard modules in backend application
    enableModule sfGuardAuth $BACKEND_APP_NAME
    enableModule sfGuardGroup $BACKEND_APP_NAME
    enableModule sfGuardUser $BACKEND_APP_NAME
    enableModule sfGuardPermission $BACKEND_APP_NAME

    enableSfGuardAuth $BACKEND_APP_NAME

    # Secure some modules or your entire application in security.yml
    sed -i -e "s/off/on/" apps/$BACKEND_APP_NAME/config/security.yml

    # fix permissions
    php symfony fix-perms

    # Rebuild your model
    #php symfony doctrine:build-model
    #php symfony doctrine:build-sql
    #php symfony doctrine:insert-sql
    php symfony doctrine:build-all-reload --no-confirmation
}

sfDoctrineGuardExtraPlugin()
{
    # Dependencies
    sfDoctrineGuardPlugin

    svn2tgzPlugin $FUNCNAME 3.0.0 "http://svn.symfony-project.com/plugins/$FUNCNAME/branches/1.3"
    installPlugin $FUNCNAME 3.0.0

    # Enable modules & plugin
    enableModule sfGuardForgotPassword $FRONTEND_APP_NAME
    enableModule sfGuardRegister $FRONTEND_APP_NAME

    enablePlugin $FUNCNAME

    # Routes already enabled by route_register=true

    # Add method `retrieveByUsernameOrEmailAddress` to get a user by email or username
    sed -i -e "s/^}$//" lib/model/doctrine/sfDoctrineGuardPlugin/sfGuardUserTable.class.php
    echo "
    static public function retrieveByUsernameOrEmailAddress(\$usernameOrEmail, \$isActive = true )
    {
        return Doctrine_Query::create()->from('sfGuardUser u')->where( '(u.username = ? OR u.email = ?) AND u.is_active = ?', array( \$usernameOrEmail, \sfGuardExtraMail$usernameOrEmail, \$isActive ) )->execute()->getFirst();
    }
}
" >> lib/model/doctrine/sfDoctrineGuardPlugin/sfGuardUserTable.class.php

    # Add getter and setter for `email_address`
    sed -i -e "s/^}$//" lib/model/doctrine/sfDoctrineGuardPlugin/sfGuardUser.class.php
    echo "
    public function getEmailAddress()
    {
      return \$this->email;
    }
    public function setEmailAddress(\$email)
    {
      \$this->email = \$email;
    }
}
" >> lib/model/doctrine/sfDoctrineGuardPlugin/sfGuardUser.class.php

    # Email delivery
    # You can override the mail delivery system simple copy `plugins/sfDoctrineGuardExtraPlugin/lib/sfGuardExtraMail.class.php` to your lib folder and override the send method.
}

csDoctrineActAsSortablePlugin()
{
    installPlugin $FUNCNAME 1.0.3
    echo "You'll need to add actAs: [Sortable] to your schema.yml"
    enablePlugin $FUNCNAME
}

sfDoctrineActAsTaggablePlugin()
{
    installPlugin $FUNCNAME 0.0.7
    echo "You'll need to add actAs: [taggable] to your schema.yml"
    enablePlugin $FUNCNAME
}

csDoctrineActAsCategorizablePlugin()
{
    installPlugin $FUNCNAME 1.0.0
    echo "You'll need to add actAs: [Categorizable] to your schema.yml"
    # Enable plugin
    enablePlugin $FUNCNAME
}

sfDoctrineActAsRattablePlugin()
{
    upgradeDoctrine

    svn2tgzPlugin $FUNCNAME 0.0.1 http://svn.symfony-project.com/plugins/$FUNCNAME/trunk
    installPlugin $FUNCNAME 0.0.1
    echo "You'll need to add actAs: [Rattable] to your schema.yml"
    enablePlugin $FUNCNAME
}
sfEventCalendarPlugin()
{
    installPlugin $FUNCNAME 1.0.1
    enablePlugin $FUNCNAME
}

pkContextCMSPlugin()
{
    # Dependencies
    sfJqueryReloadedPlugin
    pkToolkitPlugin
    pkMediaCMSSlotsPlugin
    installZend

    installPlugin $FUNCNAME 0.9.1

    # Enable
    enablePlugin $FUNCNAME
    enableModule pkContextCMSText $FRONTEND_APP_NAME
    enableModule pkContextCMSRichText $FRONTEND_APP_NAME
    enableModule pkContextCMS $FRONTEND_APP_NAME
    enableModule pkContextCMSImage $FRONTEND_APP_NAME
    enableModule sfGuardAuth $FRONTEND_APP_NAME

    echo "    rich_text_fck_js_dir:   pkToolkitPlugin/js/fckeditor" >> apps/$FRONTEND_APP_NAME/config/settings.yml

    sed -i -e "s/javascripts:\(.*\)]/javascripts: \1, \/pkToolkitPlugin\/js\/pkControls.js ]/" apps/$FRONTEND_APP_NAME/config/view.yml

    # Customize templates
    TEMP_DIR=apps/$FRONTEND_APP_NAME/modules/pkContextCMS/templates
    mkdir -p $TEMP_DIR
    # Copy templates
    cp  plugins/pkContextCMSPlugin/modules/pkContextCMS/templates/homeTemplate.php \
        plugins/pkContextCMSPlugin/modules/pkContextCMS/templates/defaultTemplate.php \
        plugins/pkContextCMSPlugin/modules/pkContextCMS/templates/_login.php \
        plugins/pkContextCMSPlugin/modules/pkContextCMS/templates/_tabs.php \
        $TEMP_DIR

    # Fix routing rule name bug
    sed -i -e "s/\/logout/sf_guard_signout/" -e "s/\/login/sf_guard_signin/" ./apps/$FRONTEND_APP_NAME/modules/pkContextCMS/templates/_login.php

    # Customize routing
    echo "
# Must be the last rule, and must have this name

pk_context_cms_page:
  url:   /cms/:slug
  param: { module: pkContextCMS, action: show }
  requirements: { slug: .* }
" >> apps/$FRONTEND_APP_NAME/config/routing.yml

    echo "
    pkContextCMS:
      routes_register: false
" >> apps/$FRONTEND_APP_NAME/config/settings.yml

    enableSfGuardAuth $FRONTEND_APP_NAME

    php symfony doctrine:build-all-load
    php symfony project:permissions
    clearCache
}

sfJqueryReloadedPlugin()
{
    installPlugin $FUNCNAME 1.2.4
    enablePlugin $FUNCNAME
}

pkToolkitPlugin()
{
    installPlugin $FUNCNAME 0.9.2
    enablePlugin $FUNCNAME
}

pkMediaPlugin()
{
    # Dependencies
    pkToolkitPlugin
    pkPersistentFileUploadPlugin
    sfJqueryReloadedPlugin
    sfDoctrineActAsTaggablePlugin
    pkImageConverterPlugin
    installZend

    installPlugin $FUNCNAME 0.9.2
    enablePlugin $FUNCNAME

    sed -i -e "/<\/IfModule>/d" web/.htaccess
    echo "
  ###### BEGIN special handling for the media module's cached scaled images
  # If it exists, just deliver it
  RewriteCond %{REQUEST_URI} ^/uploads/media_items/.+$
  RewriteCond %{REQUEST_FILENAME} -f
  RewriteRule .* - [L]
  # If it doesn't exist, render it via the front end controller
  RewriteCond %{REQUEST_URI} ^/uploads/media_items/.+$
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteRule ^(.*)$ index.php [QSA,L]
  ###### END special handling for the media module's cached scaled images
</IfModule>
" >> web/.htaccess
    mkdir -p data/pk_writable
    sudo chown www-data:www-data data/pk_writable

    enableModule pkMedia $FRONTEND_APP_NAME
}

pkMediaCMSSlotsPlugin()
{
    # Dependencies
    pkMediaPlugin

    installPlugin $FUNCNAME 0.9.1
    enablePlugin $FUNCNAME
}

pkPersistentFileUploadPlugin()
{
    installPlugin $FUNCNAME 1.0.0
    enablePlugin $FUNCNAME
}

pkImageConverterPlugin()
{
    installPlugin $FUNCNAME 1.0.0
    enablePlugin $FUNCNAME

    PPMTOGIF="$(which ppmtogif)"
    if [ -z $PPMTOGIF ]; then
        sudo aptitude -y install netpbm
    fi
    PPMTOGIF="$(which ppmtogif)"

    isConfigured=$(grep pkimageconverter apps/$FRONTEND_APP_NAME/config/settings.yml)
    if [ -z $isConfigured ]; then
        echo "
    pkimageconverter:
      path: $PPMTOGIF
" >> apps/$FRONTEND_APP_NAME/config/settings.yml
    fi
}

enableSfGuardAuth()
{
    sed -i -e "s/^#    login_module.*$/    login_module:          sfGuardAuth/" -i -e "s/^#    login_action.*$/    login_action:          signin/" -i -e "s/^#    secure_module.*$/    secure_module:         sfGuardAuth/" -i -e "s/^#    secure_action.*$/    secure_action:         secure/" apps/$1/config/settings.yml

    sed -i -e "s/sfBasicSecurityUser/sfGuardSecurityUser/" ./apps/$1/lib/myUser.class.php

    # Optionally add the following routing rules to routing.yml
    sed -i "1isf_guard_signin:\n  url:   /login\n  param: { module: sfGuardAuth, action: signin }\n\nsf_guard_signout:\n  url:   /logout\n  param: { module: sfGuardAuth, action: signout }\n\nsf_guard_password:\n  url:   /request_password\n  param: { module: sfGuardAuth, action: password }\n" apps/$1/config/routing.yml
}

enableMySQLi18n()
{
    # Enable MySQL
    echo "
  i18n:
    class: sfI18N
    param:
      source:               MySQL
      database:             mysql://$DB_USER:$DB_PASS@localhost/$DB_NAME
      debug:                on
      untranslated_prefix:  "[T]"
      untranslated_suffix:  "[/T]"
      cache:
        class: sfFileCache
        param:
          automatic_cleaning_factor: 0
          cache_dir:                 %SF_I18N_CACHE_DIR%
          lifetime:                  31556926
          prefix:                    %SF_APP_DIR%/i18n" >> apps/$FRONTEND_APP_NAME/config/factories.yml

    echo "    i18n:                   on" >>                apps/$FRONTEND_APP_NAME/config/settings.yml
    echo "    default_culture:        en" >>                apps/$FRONTEND_APP_NAME/config/settings.yml
    echo "    charset:                utf-8" >>             apps/$FRONTEND_APP_NAME/config/settings.yml
    echo "    standard_helpers:       [I18N, Partial]" >>   apps/$FRONTEND_APP_NAME/config/settings.yml

    sed -i -e "/this->db = \$this->connect();/a\    mysql_query(\"SET CHARACTER SET utf8\", \$this->db);\n    mysql_query(\"SET NAMES utf8\", \$this->db);/" -e "s/\@mysql_close(\$this->db);/\/\/\@mysql_close(\$this->db);/" lib/vendor/symfony/current_lib/i18n/sfMessageSource_MySQL.class.php

echo "
Catalogue:
  tableName: catalogue
  columns:
    cat_id:
      type: integer(4)
      primary: true
      autoincrement: true
    name:
      type: string(100)
      default: ''
      notnull: true
    source_lang:
      type: string(100)
      default: ''
      notnull: true
    target_lang:
      type: string(100)
      default: ''
      notnull: true
    date_created:
      type: integer(4)
      default: '0'
      notnull: true
    date_modified:
      type: integer(4)
      default: '0'
      notnull: true
    author:
      type: string(255)
      default: ''
      notnull: true
TransUnit:
  tableName: trans_unit
  columns:
    msg_id:
      type: integer(4)
      primary: true
      autoincrement: true
    cat_id:
      type: integer(4)
      default: '1'
      notnull: true
    id:
      type: string(255)
      default: ''
      notnull: true
    source:
      type: string()
      notnull: true
    target:
      type: string()
      notnull: true
    comments:
      type: string()
      notnull: true
    date_added:
      type: integer(4)
      default: '0'
      notnull: true
    date_modified:
      type: integer(4)
      default: '0'
      notnull: true
    author:
      type: string(255)
      default: ''
      notnull: true
    translated:
      type: integer(1)
      default: '0'
      notnull: true
" > config/doctrine/i18n.yml

    # Language Catalogues FIXTURES
echo "catalogue:" > data/fixtures/catalogue.yml

    for LANGUAGE in $LANGUAGES_TO_INSTALL; do
        if [ "$LANGUAGE" != "en" ];then
            echo "
  messages.$LANGUAGE:
    name:        'messages.$LANGUAGE'
    source:      'en'
    target_lang: $LANGUAGE" >> data/fixtures/catalogue.yml
        fi
    done
}

sfLanguageSwitchPlugin()
{
    APP_NAME=$FRONTEND_APP_NAME
    # HACK!!!!!!!!!!
    if [ -z $APP_NAME ];then
        APP_NAME=frontend
    fi
    installPlugin $FUNCNAME 0.0.5
    enablePlugin $FUNCNAME
    enableModule sfLanguageSwitch $APP_NAME

    echo "
  sfLanguageSwitch:
    flagPath:  /sfLanguageSwitch/images/flag   # optional if you wanna change the path
    availableLanguages:
      en:
        title: English
        image: /sfLanguageSwitch/images/flag/us.png   # optional if you wanna change the flag
      es:
        title: Español
        image: /sfLanguageSwitch/images/flag/es.png   # optional if you wanna change the flag
" >> apps/$APP_NAME/config/app.yml

    echo "<?php include_component('sfLanguageSwitch', 'get') ?>" >> apps/$APP_NAME/templates/layout.php
    echo "Component sfLanguageSwitch appended to apps/$APP_NAME/templates/layout.php"

    mkdir -p apps/$APP_NAME/modules/sfLanguageSwitch
    cp -r plugins/sfLanguageSwitchPlugin/modules/sfLanguageSwitch/templates apps/$APP_NAME/modules/sfLanguageSwitch
}
