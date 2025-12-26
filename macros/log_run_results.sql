{% macro log_run_results(results) %}
  {# only run when dbt is executing, not parsing #}
  {% if execute %}

    {% set insert_sqls = [] %}

    {# iterate over results from this run #}
    {% for res in results %}
      {% set node = res.node %}
      {% set adapter_response = res.adapter_response or {} %}

      {% set rows_affected = none %}
      {% if adapter_response is mapping and adapter_response.get('rows_affected') is not none %}
        {% set rows_affected = adapter_response.get('rows_affected') %}
      {% elif adapter_response is mapping and adapter_response.get('rows_inserted') is not none %}
        {% set rows_affected = adapter_response.get('rows_inserted') %}
      {% endif %}

      {% set sql %}
        INSERT INTO COWJACKET.OBSERVABILITY.DBT_RUN_LOGS (
          logged_at,
          invocation_id,
          run_started_at,
          environment,
          target_name,
          target_database,
          target_schema,
          target_warehouse,
          node_id,
          resource_type,
          model_name,
          materialization,
          status,
          execution_time_seconds,
          rows_affected,
          message
        )
        VALUES (
          CURRENT_TIMESTAMP(),
          '{{ invocation_id }}',
          '{{ run_started_at }}',
          '{{ env_var("DBT_ENVIRONMENT_NAME", target.name) }}',
          '{{ target.name }}',
          '{{ target.database }}',
          '{{ target.schema }}',
          '{{ target.warehouse if target.warehouse is defined else "" }}',
          '{{ node.unique_id }}',
          '{{ node.resource_type }}',
          '{{ node.name }}',
          '{{ node.config.materialized if node.config is defined else "" }}',
          '{{ res.status }}',
          {{ res.execution_time }},
          {{ rows_affected if rows_affected is not none else 'NULL' }},
          '{{ (res.message or "") | replace("'", "''") }}'
        );
      {% endset %}

      {% do insert_sqls.append(sql) %}
    {% endfor %}

    {% for stmt in insert_sqls %}
      {% do run_query(stmt) %}
    {% endfor %}

  {% endif %}
{% endmacro %}