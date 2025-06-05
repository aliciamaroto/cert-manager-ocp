#Install Cert Manager Operator

oc create -f 01-install-operator/ns-cert-manager.yaml
oc create -f 01-install-operator/og-cert-manager.yaml
oc create -f 01-install-operator/subs-cert-manager.yaml

echo -e "\nWaiting for the operator to finish install..."
sleep 20
oc wait --for=condition=Ready pod --all -n cert-manager --timeout=120s

