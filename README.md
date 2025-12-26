# CowJacket dbt Cloud Analytics

## Project Overview

This repository contains a full dbt Cloud analytics implementation for CowJacket, built on Snowflake, with a strong emphasis on correctness, clarity, and long-term maintainability.

The goal of the project is not just to transform data, but to demonstrate how to design an analytics system that:

 - Preserves raw data as immutable truth

 - Encodes business meaning explicitly

 - Separates concerns through layered modeling

 - Enforces trust through tests and CI

 - Provides operational observability directly in the warehouse

This project is intentionally designed to resemble a real production analytics stack, even though the dataset is small.

---

## Project Details

- Data Warehouse: Snowflake

- Transformation Tool: dbt Cloud

- Environments: Development, Staging (CI), Production

- Modeling Approach: Layered analytics engineering

- CI Strategy: Full build CI (state-based CI supported by design)

- Observability: Warehouse-native dbt run metadata logging

---

## Architecture Overview

At a high level, the system follows this flow:

`` bash
Snowflake (RAW schema)
        ↓
   dbt Sources
        ↓
   Staging Models (stg_*)
        ↓
 Intermediate Models (int_*)
        ↓
 Business Marts (fct_*)

```

Key architectural principles:

 - dbt **never mutates** raw data

 - Each layer has a clearly defined responsibility

 - Business meaning is asserted only at the mart layer

 - Environment boundaries are enforced through schema separation and guardrails

---

## Environments & Promotion Strategy

The dbt Cloud project is configured with three environments.

**Development**

 - Used for exploratory work and iteration

 - Models are disposable

 - Developers can experiment freely

**Staging (CI)**

 - Used for automated validation

 - All models and tests must pass

 - Acts as the gatekeeper before production

**Production**

 - Contains trusted, business-facing models

 - Changes are introduced only after CI validation

 - Production runs generate the canonical dbt artifacts

A **direct promotion strategy** is used: once CI passes, models can be promoted directly to production without re-implementation.

---

## Data Sources

Raw operational data is loaded into Snowflake under a dedicated RAW schema and declared in dbt as sources.

### Source Tables

`customers`
`products`
`orders`
`order_items`
`loyalty_points`

These tables are treated as authoritative and immutable.
Any inconsistencies or changes are handled downstream via transformations, not by modifying raw data.

Source definitions include:

 - Table-level documentation

 - Column-level descriptions

 - Light-touch identity tests where appropriate

---

## Staging Layer

### Purpose

The staging layer provides clean, predictable representations of raw data.

Staging models:

 - Rename columns consistently

 - Select only relevant fields

 - Standardize naming and types

 - Contain no joins, aggregations, or business logic

### Staging Models

`stg_customers`
`stg_products`
`stg_orders`
`stg_order_items`
`stg_loyalty_points`

This layer isolates upstream volatility and reduces cognitive load for downstream modeling.

---

## Intermediate Layer

### Purpose

The intermediate layer centralizes relational complexity and grain decisions.

Rather than repeating complex joins across marts, relationships are resolved once and reused.

### Core Intermediate Model

`int_customer_orders`

 - Grain: one row per order item

 - Joins orders and order_items

 - Carries customer context

 - Preserves item-level revenue truth

 - Avoids aggregation or business interpretation

This model acts as a stable foundation for multiple downstream analytical use cases.

---

## Mart Layer

### Purpose

Marts are where business meaning is asserted.

This is the only layer where:

 - Aggregations occur

 - Metrics are defined

 - Grain is deliberately re-asserted

 - Models are intended for stakeholder consumption

### Primary Mart

`fct_orders`

 - Grain: one row per order

 - Aggregates item-level truth into order-level metrics

 - Metrics include:

    - Order revenue

    - Total items

    - Line count

    - Average line value

This model is materialized as a table in a dedicated schema (`ANALYTICS_MARTS`) and includes an environment guardrail to prevent materialization in development.

---

## Testing Strategy

Testing is applied **intentionally**, aligned with each layer’s responsibility.

### Source Tests

 - Identity and sanity checks only

 - Examples:

    - `not_null`
    
    - `unique` on primary keys

### Staging Models

 - Minimal or no tests

 - Staging enforces structure, not correctness

### Intermediate Models

 - Structural tests to catch broken joins or grain violations

---

## Mart Models

Business-critical assertions, including:

 - Grain enforcement (`order_id` unique and not null)

 - Non-negative revenue checks

 - Revenue reconciliation against item-level truth

Tests are designed to surface violated assumptions, not to over-constrain valid data evolution.

## Continuous Integration (CI/CD)

A CI job runs in the staging environment to validate all models and tests on every change.

### CI Command

```bash
dbt build
```
---

### State-Based CI Design

The project architecture supports state-based CI with deferral using:

```bash
dbt build --select state:modified+ --defer
```

However, during development on the dbt Cloud Starter trial, cross-job artifact persistence is not reliably available.
For this reason, CI is intentionally locked to full builds while preserving a design that can switch to state-based CI without any code changes once artifact persistence is enabled.

This trade-off is explicitly documented and intentional.

---

## Exposures

Exposures are used to declare who consumes the data and why.

### Example Exposure

 - Name: order_level_revenue_dashboard

 - Type: Dashboard

 - Maturity: High

 - Depends On: fct_orders

Exposures improve lineage clarity and communicate the real-world impact of changes to downstream consumers.

---

## Observability & Logging

Operational observability is implemented using an on-run-end hook that logs dbt run metadata directly into Snowflake.

### Logged Metadata Includes

 - Model or test name

 - Resource type

 - Execution status

 - Execution duration

 - Rows affected (when available)

 - Environment and target schema

 - Invocation and run timestamps

### Storage Location

```bash
COWJACKET.OBSERVABILITY.DBT_RUN_LOGS
```

This provides a warehouse-native audit trail for:

 - Performance monitoring

 - Failure investigation

 - Historical analysis of dbt behavior

Observability is treated as a first-class feature, not an afterthought.

---

## Running the Project

### Prerequisites

 - Snowflake account

 - dbt Cloud project connected to this repository

 - Required Snowflake roles, warehouse, and schemas configured

### Common Commands

Run all models and tests:
```bash
dbt build
```

Run a specific model:
```bash
dbt build --select fct_orders
```

Run staging only:
```bash
dbt build --select stg_*
```

## Repository Structure

```bash
.
├── dbt_project.yml
├── packages.yml
├── models/
│   ├── sources/
│   ├── staging/
│   ├── intermediate/
│   ├── marts/
│   └── exposures/
├── macros/
├── tests/
└── README.md

```

---

## Key Design Principles

 - Raw data is authoritative and immutable

 - Meaning is asserted only at the mart layer

 - Complexity is centralized, not duplicated

 - Tests encode assumptions, not preferences

 - Environment boundaries protect truth

 - Observability is built in, not bolted on

---

## Future Enhancements

Potential next steps include:

 - Incremental models for larger datasets

 - Slowly changing dimensions for customer attributes

 - Snapshotting for historical product pricing

 - Extended observability with Git metadata

 - Transition to state-based CI once artifacts persist

---

## Final Note

This project reflects an analytics engineering mindset, prioritizing clarity, trust, and long-term sustainability over quick wins.

It is designed to scale in complexity without sacrificing understanding.