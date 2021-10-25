import numpy as np
import aspycgal
import traceback


def main():
    for i, obb in enumerate([
        {'center': np.zeros(3), 'R': np.eye(3), 'extent': np.ones(3)},
        {'center': np.zeros(3), 'R': np.eye(3), 'extent': (10, 1, None)},
        {'center': np.zeros(3), 'R': np.eye(3), 'extent': np.ones(3)},
    ]):
        try:
            print(f'P{i + 1}')
            P = aspycgal.Polyhedron_from_obb(obb)
            print(f"    vertices: {P.vertices.tolist()}")
            print(f"    edges: {P.edges.tolist()}")
            print(f"    faces: {P.faces}")
            print(f"    volume: {P.get_volume()}")
        except:
            print("Error building polygon...")
            traceback.print_exc()


if __name__ == '__main__':
    main()