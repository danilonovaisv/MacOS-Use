/**
 * Schema definition for macOS System Audit CMDB Database Logging
 */

export interface SystemAuditMetrics {
  timestamp: string;
  system: {
    hostname: string;
    os_version: string;
    os_build: string;
    arch: string;
    model: string;
    cpu: string;
    cpu_cores: number;
    memory_gb: number;
  };
  battery: {
    percentage: number;
    state: string;
  };
  storage: {
    free_gb: number;
    total_gb: number;
    usage_percentage: number;
  };
}

export interface DefaultsConfigEntry {
  domain: string;
  key: string;
  type: 'bool' | 'int' | 'string' | 'float';
  value: boolean | number | string;
  postAction?: string | null;
}

export interface SystemAuditPayload {
  id?: string;
  timestamp: string;
  agent_id: string;
  metrics: SystemAuditMetrics;
  applied_defaults?: DefaultsConfigEntry[];
  status: 'SUCCESS' | 'DRY_RUN' | 'FAILED';
}
