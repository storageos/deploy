# StorageOS Upgrade Helper

This section aims to help users with the StorageOS upgrade from any version
of StorageOS to +1.4.

StorageOS 1.4 incorporates metadata changes that require a migration if running
a previous version of StorageOS. Such a metadata migration is automated and
fully handled by the StorageOS software. However, is of paramount importance to
ensure the right version of the StorageOS components is installed.

> This section presents helpers with instructions that need to be followed from
> the [official documentation](https://docs.storageos.com/docs/operations/upgrades).


The helper script `prepare-upgrade.sh` uses kubectl. Hence, it is required to
run it in a location with access to your Kubernetes cluster.
