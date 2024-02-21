# Delivery Database

## Introduction
This project consists of a comprehensive database setup designed to manage and
track deliveries, including details about suppliers, components, projects, and
deliveries.

## Database Schema

The database is structured around four main tables: Furnizori (Suppliers),
Componente (Components), Proiecte (Projects), and Livrari (Deliveries), with
relationships defined among them through primary and foreign keys. Additionally,
constraints and triggers are used to maintain data integrity and automate certain
operations.

## Tables

• Furnizori: Stores supplier information.

• Componente: Contains details about components, including a constraint for
  color values.

• Proiecte: Lists projects, with a special constraint for projects in "Dej"

• Livrari: Records deliveries, including quantities and relationships to
  suppliers, components, and projects.

## Alterations and Constraints

• Modifications include dropping and adding columns and adding check
  constraints to ensure data validity.

• Triggers and procedures are implemented for automated data management
and integrity checks.

## Usage Examples

• Adding a Delivery: Navigate to the 'Add Delivery' section, fill in the details,
and submit.

• Searching for Components: Use the search feature in the 'Components'
section to filter components by color, weight, or city.
