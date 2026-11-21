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

cell_width, cell_height = 9, 9

# PR boundary — required for macro placement
cell.add(gdstk.rectangle(
    (0, 0), (cell_width, cell_height),
    layer=BOUNDARY_LAYER, datatype=BOUNDARY_DATATYPE,
))

points = [(0, 8), (1, 8), (1, 9), (3, 9), (3, 8), (4, 8), (4, 7), (5, 7), (5, 8), (6, 8), (6, 9), (8, 9), (8, 8), (9, 8), (9, 4), (8, 4), (8, 3), (7, 3), (7, 2), (6, 2), (6, 1), (5, 1), (5, 0), (4, 0), (4, 1), (3, 1), (3, 2), (2, 2), (2, 3), (1, 3), (1, 4), (0, 4)]

poly = gdstk.Polygon(points, layer=ART_LAYER, datatype=ART_DATATYPE)

# Simple art: one met4 rectangle
cell.add(poly)

cell.write_svg("../macros/soul.svg")
lib.write_gds("../macros/soul.gds")

bounds = (0, 0, cell_width, cell_height)
write_lef("../macros/soul.lef", CELL_NAME, bounds)
