# Monitoring et Observabilité

## Prometheus

### Déploiement

**Option 1 : Docker Compose**
```bash
docker-compose -f monitoring/docker-compose-prometheus.yml up -d
```

**Option 2 : Kubernetes**
```bash
kubectl apply -f monitoring/prometheus/prometheus-deployment.yaml -n rd-microservices
```

**Accès :**
- Prometheus UI : http://localhost:9090
- Métriques Gateway : http://localhost:8080/actuator/prometheus
- Métriques Auth : http://localhost:8081/actuator/prometheus

## Grafana

### Déploiement

```bash
docker run -d -p 3000:3000 --name=grafana grafana/grafana
```

**Configuration :**
1. Se connecter à http://localhost:3000 (admin/admin)
2. Ajouter Prometheus comme source de données
3. Importer les dashboards depuis `monitoring/grafana/dashboards/`

## ELK Stack (Optionnel)

Voir `PROJECT_IMPLEMENTATION.md` pour la configuration ELK.

