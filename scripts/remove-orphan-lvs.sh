#!/bin/bash
VG_NAME="vg1" # Change to your TopoLVM volume group name if different

echo "Fetching active TopoLVM volume IDs from Kubernetes..."
# Ensure kubectl is configured and has access to the cluster
ACTIVE_IDS=$(kubectl get logicalvolumes --all-namespaces -o jsonpath='{.items[*].status.volumeID}')

if [ -z "$ACTIVE_IDS" ]; then
    echo "Warning: No active LogicalVolumes found via kubectl, or kubectl failed. Aborting safety check."
    exit 1
fi

echo "Active IDs from LogicalVolumes in OpenShift"
echo $ACTIVE_IDS
exit 0

echo "Scanning LVM logical volumes in volume group: $VG_NAME..."
LOCAL_LVS=$(sudo lvs --noheadings -o lv_name "$VG_NAME" | tr -d ' ')

for LV in $LOCAL_LVS; do
    # Skip if LV name is not a UUID-like structure used by topolvm
    if [[ ! "$LV" =~ ^[0-9a-fA-F-]{36}$ ]]; then
        echo "Skipping non-TopoLVM or system LV: $LV"
        continue
    fi

    if echo "$ACTIVE_IDS" | grep -q "$LV"; then
        echo "Keeping active volume: $LV"
    else
        echo "Found ORPHANED logical volume: $LV"
        read -p "Do you want to remove $VG_NAME/$LV? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo lvremove -f "$VG_NAME/$LV"
            echo "Removed $LV"
        else
            echo "Skipped $LV"
        fi
    fi
done
