import math
import numpy as np
import aspycgal

def reindent(text, indent="    ", linesep="\n"):
    return linesep.join(indent + l for l in text.split(linesep))

def chunks(items, chlen, sep=""):
    for i in range(0, len(items), chlen):
        yield sep.join(items[i: i+ chlen])

def fmt_tableau(items, indent="", width=80, sep=" ", linesep="\n"):
    if len(items) > 0:
        items = list(map(str, items))
        cw = max(map(len, items))
        wcw = math.ceil(width / (cw + len(sep)))
        items = list(map("{{:{}}}".format(cw).format, items))
    else:
        wcw, items = 1, ["(empty)"]

    return reindent(linesep.join(chunks(items, wcw, sep)), indent, linesep)

def print_poly(P, name):
    print(f"{name}:")
    print("  vertices:\n{}".format(fmt_tableau(P.vertices.tolist(), "    ")))
    print("  edges:\n{}".format(fmt_tableau(P.edges.tolist(), "    ")))
    print("  faces:\n{}".format(fmt_tableau(P.faces, "    ")))
    print("  volume: {}".format(P.get_volume()))


def main():
    P1 = aspycgal.Polyhedron()
    print_poly(P1, 'P1')


    P2 = aspycgal.Polyhedron_from_obb({'center': np.zeros(3), 'R': np.eye(3), 'extent': np.ones(3)})
    print_poly(P2, 'P2')

    P3 = aspycgal.Polyhedron_from_vertices_faces(
        ((0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1)),
        ((0, 2, 1), (0, 1, 3), (0, 3, 2), (1, 2, 3)),
    )
    print_poly(P3, 'P3')


if __name__ == '__main__':
    main()