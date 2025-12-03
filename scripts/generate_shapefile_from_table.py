import psycopg2
import geopandas as gpd
from shapely import wkb, wkt
import pandas as pd

# Connection details
host = "psql-dsp-ea-geoserver-prod-uksouth-01.postgres.database.azure.com"
dbname = "dsp-ea-geospatial"
user = "agripgsqladmin"
password = ""
schema = "ea_admin"
table = "ea_wfd_river_canal_and_swt_water_bodies_cycle_3_class_2022"
geom_col = "shape"  # your geometry column
output_shp = "Water_Framework_Directive_WFD_River_Canal_and_Surface_Water_Transfer_Water_Bodies_Cycle_3_Classification_2022_Full_Resolution.shp"

# Connect to Postgres with SSL
conn = psycopg2.connect(
    host=host,
    dbname=dbname,
    user=user,
    password=password,
    sslmode="require"
)

cur = conn.cursor()

# Fetch all rows
cur.execute(f"SELECT * FROM {schema}.{table};")
rows = cur.fetchall()

# Column names
colnames = [desc[0] for desc in cur.description]

# Build DataFrame
df = pd.DataFrame(rows, columns=colnames)

# Convert geometry column to shapely
def parse_geometry(val):
    if val is None:
        return None
    if isinstance(val, memoryview):  # WKB
        return wkb.loads(val.tobytes())
    if isinstance(val, str):  # HEX or WKT
        try:
            return wkb.loads(bytes.fromhex(val))  # try HEX
        except Exception:
            return wkt.loads(val)  # fallback WKT
    return val

df[geom_col] = df[geom_col].apply(parse_geometry)

# Create GeoDataFrame
gdf = gpd.GeoDataFrame(df, geometry=geom_col, crs="EPSG:4326")

# Export to Shapefile
gdf.to_file(output_shp)

print(f"Shapefile created: {output_shp}")

cur.close()
conn.close()
