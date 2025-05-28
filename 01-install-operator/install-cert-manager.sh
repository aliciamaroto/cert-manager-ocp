#Install Cert Manager Operator

oc create -f ns-cert-manager.yaml
oc create -f og-cert-manager.yaml
oc create -f subs-cert-manager.yaml

oc wait --for=condition=Ready pod --all -n cert-manager --timeout=120s

