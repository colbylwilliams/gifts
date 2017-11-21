#!/usr/bin/env bash


infoPlist="$MOBILECENTER_SOURCE_DIRECTORY/gifts/gifts/Info.plist"


plutil -replace ADDatabaseAccountName -string "$AZURE_COSMOS_DB_ACCOUNT_NAME" "$infoPlist"
plutil -replace ADDatabaseAccountKey -string "$AZURE_COSMOS_DB_ACCOUNT_KEY" "$infoPlist"


plutil -replace AMNotificationHubName -string "$AZURE_NOTIFICATIONHUB_NAME" "$infoPlist"
plutil -replace AMNotificationHubConnection -string "$AZURE_NOTIFICATIONHUB_CONNECTION" "$infoPlist"
