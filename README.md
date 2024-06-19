# instana-examples

This repository hosts examples of various ways to use Instana.

## Jaeger Instrumentation

### Hotel Reservation

To deploy the Hotel Reservation application to a Kubernetes cluster, run the following commands in the `jaeger-instrumentation/hotelreservation` directory:

```bash
make hotel-reservation
make deploy
```

This will download the release archive, use Helm to install the application and workload generator client, and configure the Jaeger configuration to send traces to Instana instead of the Jaeger service.

To remove the application and client, run the following command:

```bash
make undeploy
```