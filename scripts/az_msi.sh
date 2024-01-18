#!/bin/bash

echo 'Setting up az cli to use managed identity'

export ARM_USE_MSI=true
export ARM_SUBSCRIPTION_ID=
export ARM_TENANT_ID=
export ARM_CLIENT_ID=
# export ARM_MSI_ENDPOINT=$MSI_ENDPOINT # only necessary when the msi endpoint is different than the well-known one
