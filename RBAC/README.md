> Contextos que tengo
kubectl config get-contexts

> Saber si tengo permisos totales en todos los namespaces
kubectl auth can-i '*' '*' --all-namespaces

> Crearemos los tres usuarios
| Usuario   | Tipo           | Permisos            |
| --------- | -------------- | ------------------- |
| admin     | Token DO       | cluster-admin       |
| developer | ServiceAccount | solo project-dev    |
| auditor   | ServiceAccount | solo lectura global |

> Y podrás cambiar así:
kubectl config use-context developer.
