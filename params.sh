#!/bin/bash

TEMP=`getopt -o hc:i:l: --long help,config-file:,install-plugin:,language: -n "$0" -- "$@"`

if [ $? != 0 ] ; then usage ; fi

eval set -- "$TEMP"

CONFIG_FILE=
PLUGINS_TO_INSTALL=
LANGUAGES_TO_INSTALL=

while true ; do
    case "$1" in
        -h|--help) usage ; break;;
        -c|--config-file) CONFIG_FILE=$2 ; shift 2 ;;
        -l|--language) LANGUAGES_TO_INSTALL="$LANGUAGES_TO_INSTALL $2"; shift 2 ;;
        -i|--install-plugin)
            case "$2" in
                sfDoctrineGuardPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfDoctrineGuardPlugin"; shift 2 ;;
                sfDoctrineGuardExtraPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfDoctrineGuardExtraPlugin"; shift 2 ;;
                sfAdminDashPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfAdminDashPlugin"; shift 2 ;;
                csDoctrineActAsSortablePlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL csDoctrineActAsSortablePlugin"; shift 2 ;;
                csDoctrineActAsAttachablePlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL csDoctrineActAsAttachablePlugin"; shift 2 ;;
                sfDoctrineActAsTaggablePlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfDoctrineActAsTaggablePlugin"; shift 2 ;;
                csDoctrineActAsCategorizablePlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL csDoctrineActAsCategorizablePlugin"; shift 2 ;;
                sfDoctrineActAsRattablePlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfDoctrineActAsRattablePlugin"; shift 2 ;;
                sfEventCalendarPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfEventCalendarPlugin"; shift 2 ;;
                sfJqueryReloadedPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfJqueryReloadedPlugin"; shift 2 ;;
                pkContextCMSPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL pkContextCMSPlugin"; shift 2 ;;
                pkToolkitPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL pkToolkitPlugin"; shift 2 ;;
                pkPersistentFileUploadPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL pkPersistentFileUploadPlugin"; shift 2 ;;
                pkImageConverterPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL pkImageConverterPlugin"; shift 2 ;;
                sfLanguageSwitchPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfLanguageSwitchPlugin"; shift 2 ;;
                csSEOToolkitPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL csSEOToolkitPlugin"; shift 2 ;;
                sfDoctrineManagerPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfDoctrineManagerPlugin"; shift 2 ;;
                sfLinkCrossAppPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfLinkCrossAppPlugin"; shift 2 ;;
                SomeMinifyPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL SomeMinifyPlugin"; shift 2 ;;
                sfDoctrineApplyPlugin) PLUGINS_TO_INSTALL="$PLUGINS_TO_INSTALL sfDoctrineApplyPlugin"; shift 2 ;;
                *) echo "Plugin not supported: \`$2'" ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) usage ;;
    esac
done

