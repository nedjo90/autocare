#!/bin/bash
BASE="https://adventurous-determination-production.up.railway.app"

TOKEN=$(curl -s -X POST $BASE/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@autocare.fr","password":"admin123"}' | python -c "import sys,json; print(json.load(sys.stdin)['data']['access_token'])")
H="Authorization: Bearer $TOKEN"
echo "Token OK"

# --- COLLECTION: site_settings (singleton for logo, images, site info) ---
echo "Creating site_settings..."
curl -s -X POST $BASE/collections -H "$H" -H "Content-Type: application/json" -d '{
  "collection": "site_settings",
  "schema": {},
  "meta": { "icon": "settings", "singleton": true, "note": "Configuration du site (logo, images, textes)" },
  "fields": [
    { "field": "id", "type": "integer", "meta": { "hidden": true, "readonly": true }, "schema": { "is_primary_key": true, "has_auto_increment": true } },
    { "field": "nom_garage", "type": "string", "schema": {}, "meta": { "interface": "input", "required": true, "note": "Nom affiche sur le site" } },
    { "field": "logo", "type": "uuid", "schema": {}, "meta": { "interface": "file-image", "special": ["file"], "note": "Logo du garage" } },
    { "field": "hero_image", "type": "uuid", "schema": {}, "meta": { "interface": "file-image", "special": ["file"], "note": "Image hero en haut du site" } },
    { "field": "adresse", "type": "string", "schema": {}, "meta": { "interface": "input" } },
    { "field": "telephone", "type": "string", "schema": {}, "meta": { "interface": "input" } },
    { "field": "hero_titre", "type": "string", "schema": {}, "meta": { "interface": "input", "note": "Titre principal du site" } },
    { "field": "hero_description", "type": "text", "schema": {}, "meta": { "interface": "input-multiline", "note": "Description sous le titre" } }
  ]
}' > /dev/null && echo "  OK"

# --- COLLECTION: services ---
echo "Creating services..."
curl -s -X POST $BASE/collections -H "$H" -H "Content-Type: application/json" -d '{
  "collection": "services",
  "schema": {},
  "meta": { "icon": "build", "note": "Services proposes par le garage" },
  "fields": [
    { "field": "id", "type": "integer", "meta": { "hidden": true, "readonly": true }, "schema": { "is_primary_key": true, "has_auto_increment": true } },
    { "field": "nom", "type": "string", "schema": {}, "meta": { "interface": "input", "required": true } },
    { "field": "description", "type": "text", "schema": {}, "meta": { "interface": "input-multiline" } },
    { "field": "image", "type": "uuid", "schema": {}, "meta": { "interface": "file-image", "special": ["file"], "note": "Image du service" } },
    { "field": "duree_minutes", "type": "integer", "schema": { "default_value": 60 }, "meta": { "interface": "input", "required": true } },
    { "field": "prix", "type": "float", "schema": {}, "meta": { "interface": "input", "required": true } },
    { "field": "actif", "type": "boolean", "schema": { "default_value": true }, "meta": { "interface": "boolean", "special": ["cast-boolean"] } }
  ]
}' > /dev/null && echo "  OK"

# --- COLLECTION: horaires ---
echo "Creating horaires..."
curl -s -X POST $BASE/collections -H "$H" -H "Content-Type: application/json" -d '{
  "collection": "horaires",
  "schema": {},
  "meta": { "icon": "schedule", "note": "Horaires ouverture du garage" },
  "fields": [
    { "field": "id", "type": "integer", "meta": { "hidden": true, "readonly": true }, "schema": { "is_primary_key": true, "has_auto_increment": true } },
    { "field": "jour", "type": "integer", "schema": {}, "meta": { "interface": "select-dropdown", "required": true, "options": { "choices": [{"text":"Lundi","value":1},{"text":"Mardi","value":2},{"text":"Mercredi","value":3},{"text":"Jeudi","value":4},{"text":"Vendredi","value":5},{"text":"Samedi","value":6}] } } },
    { "field": "heure_ouverture", "type": "string", "schema": {}, "meta": { "interface": "input", "required": true } },
    { "field": "heure_fermeture", "type": "string", "schema": {}, "meta": { "interface": "input", "required": true } }
  ]
}' > /dev/null && echo "  OK"

# --- COLLECTION: rendez_vous ---
echo "Creating rendez_vous..."
curl -s -X POST $BASE/collections -H "$H" -H "Content-Type: application/json" -d '{
  "collection": "rendez_vous",
  "schema": {},
  "meta": { "icon": "event", "note": "Rendez-vous clients" },
  "fields": [
    { "field": "id", "type": "integer", "meta": { "hidden": true, "readonly": true }, "schema": { "is_primary_key": true, "has_auto_increment": true } },
    { "field": "date_heure", "type": "dateTime", "schema": {}, "meta": { "interface": "datetime", "required": true } },
    { "field": "duree_minutes", "type": "integer", "schema": { "default_value": 60 }, "meta": { "interface": "input" } },
    { "field": "client_nom", "type": "string", "schema": {}, "meta": { "interface": "input", "required": true } },
    { "field": "client_tel", "type": "string", "schema": {}, "meta": { "interface": "input", "required": true } },
    { "field": "client_email", "type": "string", "schema": {}, "meta": { "interface": "input" } },
    { "field": "service_id", "type": "integer", "schema": {}, "meta": { "interface": "select-dropdown-m2o", "special": ["m2o"] } },
    { "field": "statut", "type": "string", "schema": { "default_value": "en_attente" }, "meta": { "interface": "select-dropdown", "options": { "choices": [{"text":"En attente","value":"en_attente"},{"text":"Confirme","value":"confirme"},{"text":"Termine","value":"termine"},{"text":"Annule","value":"annule"}] } } },
    { "field": "notes", "type": "text", "schema": {}, "meta": { "interface": "input-multiline" } }
  ]
}' > /dev/null && echo "  OK"

# --- RELATION ---
echo "Creating relation..."
curl -s -X POST $BASE/relations -H "$H" -H "Content-Type: application/json" -d '{
  "collection": "rendez_vous",
  "field": "service_id",
  "related_collection": "services"
}' > /dev/null && echo "  OK"

# --- SEED DATA ---
echo "Seeding site_settings..."
curl -s -X POST $BASE/items/site_settings -H "$H" -H "Content-Type: application/json" -d '{
  "nom_garage": "AutoCare",
  "adresse": "12 Rue de la Mecanique, 75011 Paris",
  "telephone": "01 23 45 67 89",
  "hero_titre": "Votre voiture entre de bonnes mains",
  "hero_description": "Entretien, reparation et diagnostic automobile. Prise de rendez-vous en ligne, rapide et simple."
}' > /dev/null && echo "  OK"

echo "Seeding services..."
curl -s -X POST $BASE/items/services -H "$H" -H "Content-Type: application/json" -d '[
  { "nom": "Vidange", "description": "Vidange huile moteur + filtre", "duree_minutes": 45, "prix": 89.00, "actif": true },
  { "nom": "Freinage", "description": "Remplacement plaquettes de frein", "duree_minutes": 90, "prix": 150.00, "actif": true },
  { "nom": "Pneus", "description": "Montage et equilibrage 4 pneus", "duree_minutes": 60, "prix": 60.00, "actif": true },
  { "nom": "Diagnostic", "description": "Lecture codes erreur + diagnostic complet", "duree_minutes": 30, "prix": 45.00, "actif": true },
  { "nom": "Revision complete", "description": "Revision annuelle tous points de controle", "duree_minutes": 120, "prix": 250.00, "actif": true }
]' > /dev/null && echo "  OK"

echo "Seeding horaires..."
curl -s -X POST $BASE/items/horaires -H "$H" -H "Content-Type: application/json" -d '[
  { "jour": 1, "heure_ouverture": "08:00", "heure_fermeture": "18:00" },
  { "jour": 2, "heure_ouverture": "08:00", "heure_fermeture": "18:00" },
  { "jour": 3, "heure_ouverture": "08:00", "heure_fermeture": "18:00" },
  { "jour": 4, "heure_ouverture": "08:00", "heure_fermeture": "18:00" },
  { "jour": 5, "heure_ouverture": "08:00", "heure_fermeture": "18:00" },
  { "jour": 6, "heure_ouverture": "09:00", "heure_fermeture": "13:00" }
]' > /dev/null && echo "  OK"

echo "Seeding sample RDV..."
curl -s -X POST $BASE/items/rendez_vous -H "$H" -H "Content-Type: application/json" -d '[
  { "date_heure": "2026-04-07T09:00:00", "duree_minutes": 45, "client_nom": "Jean Dupont", "client_tel": "0612345678", "client_email": "jean@test.fr", "service_id": 1, "statut": "confirme" },
  { "date_heure": "2026-04-07T14:00:00", "duree_minutes": 90, "client_nom": "Marie Martin", "client_tel": "0698765432", "client_email": "marie@test.fr", "service_id": 2, "statut": "en_attente" },
  { "date_heure": "2026-04-08T10:00:00", "duree_minutes": 60, "client_nom": "Pierre Leroy", "client_tel": "0655443322", "client_email": "pierre@test.fr", "service_id": 3, "statut": "confirme" }
]' > /dev/null && echo "  OK"

# --- Set admin static token for frontend ---
ADMIN_ID=$(curl -s "$BASE/users/me" -H "$H" | python -c "import sys,json; print(json.load(sys.stdin)['data']['id'])")
curl -s -X PATCH "$BASE/users/$ADMIN_ID" -H "$H" -H "Content-Type: application/json" \
  -d '{"token": "frontend-readonly-token"}' > /dev/null && echo "Admin token set"

echo ""
echo "=== DONE ==="
