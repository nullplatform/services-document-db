{
  "name": "AWS DocumentDB Cluster",
  "slug": "documentdb-cluster",
  "type": "dependency",
  "unique": false,
  "assignable_to": "any",
  "use_default_actions": true,
  "available_links": ["connect"],
  "selectors": {
    "category": "Database",
    "imported": false,
    "provider": "AWS",
    "sub_category": "Document Database"
  },
  "attributes": {
    "schema": {
      "type": "object",
      "$schema": "http://json-schema.org/draft-07/schema#",
      "required": ["instance_class"],
      "uiSchema": {
        "type": "VerticalLayout",
        "elements": [
          { "type": "Control", "scope": "#/properties/instance_class" },
          { "type": "Control", "scope": "#/properties/instance_count" },
          {
            "type": "Control",
            "scope": "#/properties/engine_version",
            "options": { "format": "radio" }
          },
          {
            "type": "Categorization",
            "options": { "collapsable": { "label": "ADVANCED", "collapsed": true } },
            "elements": [
              {
                "type": "Category",
                "label": "Backups",
                "elements": [
                  { "type": "Control", "scope": "#/properties/backup_retention_period" },
                  { "type": "Control", "scope": "#/properties/preferred_backup_window" }
                ]
              },
              {
                "type": "Category",
                "label": "Maintenance",
                "elements": [
                  { "type": "Control", "scope": "#/properties/preferred_maintenance_window" }
                ]
              },
              {
                "type": "Category",
                "label": "Protection",
                "elements": [
                  { "type": "Control", "scope": "#/properties/deletion_protection" }
                ]
              }
            ]
          },
          {
            "type": "Group",
            "label": "Connection",
            "elements": [
              { "type": "Control", "scope": "#/properties/endpoint" },
              { "type": "Control", "scope": "#/properties/reader_endpoint" },
              { "type": "Control", "scope": "#/properties/port" },
              { "type": "Control", "scope": "#/properties/tls_ca_url" }
            ]
          }
        ]
      },
      "properties": {
        "instance_class": {
          "type": "string",
          "title": "Instance Class",
          "default": "db.t3.medium",
          "oneOf": [
            { "const": "db.t3.medium", "title": "db.t3.medium — 2 vCPU / 4 GiB, burstable (dev, test)" },
            { "const": "db.t4g.medium", "title": "db.t4g.medium — 2 vCPU / 4 GiB, burstable Graviton (dev, test)" },
            { "const": "db.r6g.large", "title": "db.r6g.large — 2 vCPU / 16 GiB, Graviton" },
            { "const": "db.r6g.xlarge", "title": "db.r6g.xlarge — 4 vCPU / 32 GiB, Graviton" },
            { "const": "db.r5.large", "title": "db.r5.large — 2 vCPU / 16 GiB, Intel" },
            { "const": "db.r5.xlarge", "title": "db.r5.xlarge — 4 vCPU / 32 GiB, Intel" }
          ],
          "description": "Instance type for every cluster member. db.t3.medium / db.t4g.medium are the only burstable classes DocumentDB supports and the only sensible choice for non-production.",
          "editableOn": ["create", "update"],
          "order": 1
        },
        "instance_count": {
          "type": "number",
          "title": "Instance Count",
          "default": 1,
          "minimum": 1,
          "maximum": 6,
          "description": "Number of instances in the cluster. The first is the writer; the rest are read replicas. 1 means no failover target — use 2 or more for production.",
          "editableOn": ["create", "update"],
          "order": 2
        },
        "engine_version": {
          "type": "string",
          "title": "Engine Version",
          "default": "5.0.0",
          "oneOf": [
            { "const": "4.0.0", "title": "4.0.0 — MongoDB 4.0 API (legacy clients)" },
            { "const": "5.0.0", "title": "5.0.0 — MongoDB 5.0 API (recommended)" },
            { "const": "8.0.0", "title": "8.0.0 — MongoDB 8.0 API (newest)" }
          ],
          "description": "DocumentDB engine version, which maps to a MongoDB API level. Cannot be changed after creation.",
          "editableOn": ["create"],
          "order": 3
        },
        "backup_retention_period": {
          "type": "number",
          "title": "Backup Retention (days)",
          "default": 7,
          "minimum": 1,
          "maximum": 35,
          "description": "Days of automated backups to retain, for recovery while the cluster exists. DocumentDB has no zero-retention mode; the minimum is 1. This is NOT a grace period on deletion: automated backups are deleted with the cluster, and this service takes no final snapshot, so deleting it destroys the data whatever this is set to. Turn on Deletion Protection for that.",
          "editableOn": ["create", "update"],
          "order": 4
        },
        "preferred_backup_window": {
          "type": "string",
          "title": "Backup Window",
          "default": "03:00-04:00",
          "pattern": "^([01][0-9]|2[0-3]):[0-5][0-9]-([01][0-9]|2[0-3]):[0-5][0-9]$",
          "description": "Daily window for automated backups, in UTC (hh:mm-hh:mm).",
          "editableOn": ["create", "update"],
          "order": 5
        },
        "preferred_maintenance_window": {
          "type": "string",
          "title": "Maintenance Window",
          "default": "Mon:04:00-Mon:05:00",
          "pattern": "^(Mon|Tue|Wed|Thu|Fri|Sat|Sun):([01][0-9]|2[0-3]):[0-5][0-9]-(Mon|Tue|Wed|Thu|Fri|Sat|Sun):([01][0-9]|2[0-3]):[0-5][0-9]$",
          "description": "Weekly window for engine maintenance, in UTC (ddd:hh:mm-ddd:hh:mm).",
          "editableOn": ["create", "update"],
          "order": 6
        },
        "deletion_protection": {
          "type": "boolean",
          "title": "Deletion Protection",
          "default": false,
          "description": "Block cluster deletion at the AWS API level. Leave off unless this cluster holds data you cannot lose — with it on, the service delete action fails until it is turned off.",
          "editableOn": ["create", "update"],
          "order": 7
        },
        "endpoint": {
          "type": "string",
          "title": "Cluster Endpoint",
          "export": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "Writer endpoint of the cluster (auto-populated after creation). Reachable only from inside the VPC.",
          "order": 8
        },
        "reader_endpoint": {
          "type": "string",
          "title": "Reader Endpoint",
          "export": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "Load-balanced endpoint across the read replicas (auto-populated after creation).",
          "order": 9
        },
        "port": {
          "type": "number",
          "title": "Port",
          "export": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "Cluster port (auto-populated after creation). DocumentDB always listens on 27017.",
          "order": 10
        },
        "tls_ca_url": {
          "type": "string",
          "title": "TLS CA Bundle URL",
          "export": true,
          "visibleOn": ["read"],
          "editableOn": [],
          "description": "URL of the Amazon RDS global CA bundle. Clients need it to verify the cluster certificate when TLS is on.",
          "order": 11
        },
        "cluster_identifier": {
          "type": "string",
          "export": false,
          "visibleOn": [],
          "editableOn": [],
          "description": "Internal AWS DocumentDB cluster identifier"
        },
        "master_secret_arn": {
          "type": "string",
          "export": false,
          "visibleOn": [],
          "editableOn": [],
          "description": "ARN of the Secrets Manager secret holding master credentials (read by link actions to provision users)"
        },
        "security_group_id": {
          "type": "string",
          "export": false,
          "visibleOn": [],
          "editableOn": [],
          "description": "Internal ID of the security group guarding the cluster"
        }
      }
    },
    "values": {}
  }
}
