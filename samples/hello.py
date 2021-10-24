import numpy as np
import aspycgal


def print_poly(P, name):
    print(f"{name}:")
    print(f"    vertices: {P.vertices}")
    print(f"    edges: {P.edges}")
    print(f"    faces: {P.faces}")
    print(f"    volume: {P.get_volume()}")


def main():
    P1 = aspycgal.Polyhedron()
    print_poly(P1, 'P1')


    P2 = aspycgal.Polyhedron_from_obb({'center': np.zeros(3), 'R': np.eye(3), 'extent': np.ones(3)})
    print_poly(P2, 'P2')


if __name__ == '__main__':
    main()