import gdstk

CELL_NAME = "soul"

# bweeh i have no clue how this workies (skulk)
ART_LAYER, ART_DATATYPE = 46, 0   # Metal4...?
BOUNDARY_LAYER, BOUNDARY_DATATYPE = 0, 0


def write_lef(filename, cell_name, bounds):
    """Write a minimal LEF file with Metal4 obstruction. bounds = (xmin, ymin, xmax, ymax)."""
    width = bounds[2] - bounds[0]
    height = bounds[3] - bounds[1]
    with open(filename, "w") as f:
        f.write(f"# LEF file generated for {cell_name}\n")
        f.write("VERSION 5.8 ;\n")
        f.write("NAMESCASESENSITIVE ON ;\n")
        f.write("DIVIDERCHAR \"/\" ;\n")
        f.write("BUSBITCHARS \"[]\" ;\n")
        f.write("UNITS\n")
        f.write("   DATABASE MICRONS 1000 ;\n")
        f.write("END UNITS\n\n")
        f.write(f"MACRO {cell_name}\n")
        f.write("   CLASS BLOCK ;\n")
        f.write(f"   FOREIGN {cell_name} 0 0 ;\n")
        f.write(f"   SIZE {width:.3f} BY {height:.3f} ;\n")
        f.write("   SYMMETRY X Y ;\n")
        f.write("   OBS\n")
        f.write("      LAYER Metal4 ;\n")
        f.write(f"         RECT {bounds[0]:.3f} {bounds[1]:.3f} {bounds[2]:.3f} {bounds[3]:.3f} ;\n")
        f.write("   END\n")
        f.write(f"END {cell_name}\n")


lib = gdstk.Library()
cell = lib.new_cell(CELL_NAME)

cell_width, cell_height = 27, 27

# PR boundary — required for macro placement
cell.add(gdstk.rectangle(
    (0, 0), (cell_width, cell_height),
    layer=BOUNDARY_LAYER, datatype=BOUNDARY_DATATYPE,
))

points = [(0, 24), (3, 24), (3, 27), (9, 27), (9, 24), (12, 24), (12, 21), (15, 21), (15, 24), (18, 24), (18, 27), (24, 27), (24, 24), (27, 24), (27, 12), (24, 12), (24, 9), (21, 9), (21, 6), (18, 6), (18, 3), (15, 3), (15, 0), (12, 0), (12, 3), (9, 3), (9, 6), (6, 6), (6, 9), (3, 9), (3, 12), (0, 12)]

poly = gdstk.Polygon(points, layer=ART_LAYER, datatype=ART_DATATYPE)

# Simple art: one met4 rectangle
cell.add(poly)

cell.write_svg("../macros/soul.svg")
lib.write_gds("../macros/soul.gds")

bounds = (0, 0, cell_width, cell_height)
write_lef("../macros/soul.lef", CELL_NAME, bounds)
