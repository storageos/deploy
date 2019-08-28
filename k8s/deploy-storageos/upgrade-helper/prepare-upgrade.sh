#!/bin/bash

LATEST_VERSION="soegarots/node:1.4.0-rc1"
LATEST_INIT="storageos/init:develop"

PATCHED_FILES_LOC="/tmp/patched-tmp"
ONDELETE_PATCH="$PATCHED_FILES_LOC/ondelete.yaml"
INITIMAGE_PATCH="$PATCHED_FILES_LOC/initimage.yaml"

print_green() {
    local msg="$1"
    GR='\033[0;32m'
    NC='\033[0m' # No Color

    echo -e "${GR}$msg${NC}"
}

print_red() {
    local msg="$1"
    RED='\033[0;31m'
    NC='\033[0m' # No Color

    echo -e "${RED}$msg${NC}"
}

create_patches() {
    mkdir -p $PATCHED_FILES_LOC
    cat <<END > $ONDELETE_PATCH
spec:
  updateStrategy:
    type: OnDelete
END

    cat <<END > $INITIMAGE_PATCH
spec:
  template:
    spec:
      initContainers:
        - name: enable-lio
          image: $LATEST_INIT
END
}

check_operator_version() {
    echo "Checking the StorageOS Cluster Operator version"
    local out="$(kubectl get pod --all-namespaces --no-headers -ocustom-columns=_:.metadata.name,_:.metadata.namespace | grep "storageos" | grep "operator")"

    local pod="$(echo $out | cut -d' ' -f1)"
    local ns="$(echo $out | cut -d' ' -f2)"

    if [ -z "$pod" ]; then
        echo "Couldn't find the StorageOS Cluster Operator Pod"
        exit 1
    fi

    local image="$(kubectl -n $ns get pod $pod -o go-template --template="{{range .spec.containers}}{{.image}} {{end}}")"
    if [ -z "$image" ]; then
        echo "Couldn't find the image of the Operator"
        exit 1
    fi

    # TODO check versions properly, not only 1.3.0, but anything before that
    if grep -q "1.3.0" <(echo $image); then
        print_red "The Cluster Operator needs to be updated"
        echo "The image $image is not the latest"
        exit 1
        #TODO: Reference the Operator upgrades pages, uber yaml, helm, etc
    fi

    print_green "Verified StorageOS Cluster Operator version $image"
}

set_updatestrategy_ondelete() {
    local ns="$1"

    # Ensure UpdateStrategy is on Delete
    echo "Setting the UpdateStrategy of the StorageOS DaemonSet to OnDelete"
    kubectl -n "$ns" patch ds/storageos-daemonset --patch "$(cat $ONDELETE_PATCH)"
}

set_new_images() {
    local pod="$1"
    local ns="$2"

    local image="$(kubectl -n $ns get pod $pod -o go-template --template="{{range .spec.containers}}{{.image}} {{end}}" -o go-template --template="{{range .spec.containers}}{{.image}} {{end}}" | egrep -o "storageos/node:([0-9].?){3}")"
    local init_img="$(kubectl -n $ns get pod $pod -o go-template --template="{{range .spec.initContainers}}{{.image}} {{end}}")"

    if [ -z "$image" ]; then
        echo "Couldn't find the StorageOS installed version"
        exit 1
    fi

    if [ "$image" != "$LATEST_VERSION" ]; then
        if [ "$init_img" != "$LATEST_INIT" ]; then
            echo "Current init container: $init_img"
            print_green "Setting the image for the init container to $LATEST_INIT"
            kubectl -n $ns patch ds/storageos-daemonset --patch "$(cat $INITIMAGE_PATCH)"
        fi
        echo "Current StorageOS version: $image"
        print_green "Setting image for DaemonSet storageos-daemonset to $LATEST_VERSION"
        kubectl -n $ns set image ds/storageos-daemonset storageos=$LATEST_VERSION
    fi
}

list_pods_using_storageos_volumes() {
    # TODO: assess if adding a dependency to JQ is ok

    print_red "The following Pods are using StorageOS volumes."
    print_red "They need to be scaled to 0 or be restarted after StorageOS is running the newer version."
    print_red "Ensure that the StorageOS Pods are in READY state before you scale back up"
    while IFS= read -r line; do
        ns=$(cut -f1  -d' ' <(echo $line))
        pvc=$(cut -f2 -d' ' <(echo $line))

        kubectl -n $ns get pod -ojson | jq -M --arg PVC "$pvc" -r '.items[]
        | select(.spec.volumes[].persistentVolumeClaim.claimName != null)
        | select(.spec.volumes[].persistentVolumeClaim.claimName == $PVC)
        | { NameSpace: .metadata.namespace,  Pod: .metadata.name}'
    done < <(kubectl get pvc --all-namespaces -ojson \
        | jq -r '.items[]
        | select (.metadata.annotations."volume.beta.kubernetes.io/storage-provisioner"
        | test("storageos"))
        |  .metadata.namespace + " " + .metadata.name'
    )
}


####### MAIN ########

create_patches

print_green "Using the cluster: `kubectl config current-context`"
check_operator_version

# Find current StorageOS installed version
out=$(kubectl get pod --all-namespaces  -lapp=storageos,kind=daemonset --no-headers -ocustom-columns=_:.metadata.name,_:.metadata.namespace | head -1)

pod="$(cut -d' ' -f1 <(echo $out))"
ns="$(cut  -d' ' -f2 <(echo $out))"

if [ -z "$pod" ]; then
    echo "Couldn't find any StorageOS Pod"
    exit 1
fi

set_updatestrategy_ondelete $ns
set_new_images $pod $ns

# TODO: pass the required permissions for the init container to call the APIs

list_pods_using_storageos_volumes

echo "You can delete the StorageOS Pods to restart with the new version when you are ready."
print_green "kubectl -n $ns delete pod -lapp=storageos,kind=daemonset"
