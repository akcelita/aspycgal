import math
import numpy as np
import aspycgal
import traceback


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


def main():
    for i, obb in enumerate([
        {'center': np.zeros(3), 'R': np.eye(3), 'extent': np.ones(3)},
        {'center': np.zeros(3), 'R': np.eye(3), 'extent': (10, 1, None)},
        {'center': np.zeros(3), 'R': np.eye(3), 'extent': np.ones(3)},
    ]):
        print(f'P{i + 1}:')
        try:
            P = aspycgal.Polyhedron_from_obb(obb)
            print("  vertices:\n{}".format(fmt_tableau(P.vertices.tolist(), "    ")))
            print("  edges:\n{}".format(fmt_tableau(P.edges.tolist(), "    ")))
            print("  faces:\n{}".format(fmt_tableau(P.faces, "    ")))
            print("  volume: {}".format(P.get_volume()))
        except:
            print("  Error building polygon: |")
            print(reindent(traceback.format_exc().strip(), "    "))


if __name__ == '__main__':
    main()