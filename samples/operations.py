import numpy as np
import open3d as o3d
import aspycgal

def random_rot_3x3():
    X = np.random.normal(size=(3, 3))

    X /= np.cbrt(np.linalg.det(X))

    return X

def random_bbox(alpha):
    b = o3d.geometry.OrientedBoundingBox(np.random.normal(size=3), random_rot_3x3(), np.random.gamma(alpha, size=3))
    b.color = np.random.uniform(size=3)
    return b

def polyhedron_2_trimesh(p, color=None):
    trimesh = o3d.geometry.TriangleMesh(
        o3d.utility.Vector3dVector(p.vertices),
        o3d.utility.Vector3iVector(np.array(p.faces))
    )

    if color is not None:
        color = np.array(np.array(color).tolist() * 3, np.float).reshape((-1, 3))
        color = color[
            [i % len(color) for i in range(len(trimesh.vertices))]
        ]

        trimesh.vertex_colors = o3d.utility.Vector3dVector(color)
    
    return trimesh


def main():
    box1 = o3d.geometry.OrientedBoundingBox(np.zeros(3), np.eye(3), np.ones(3))
    box2 = o3d.geometry.OrientedBoundingBox(np.ones(3) * .5, random_rot_3x3(), np.ones(3))
    box1.color = (1, 0, 0)
    box2.color = (0, 0, 1)

    o3d.visualization.draw_geometries([box2, box1], window_name="boxes")

    poly1 = aspycgal.Polyhedron_from_obb({'center': box1.center, 'R': box1.R, 'extent': box1.extent})
    poly2 = aspycgal.Polyhedron_from_obb({'center': box2.center, 'R': box2.R, 'extent': box2.extent})

    print("poly1.union_with(poly2)")
    result = poly1.union_with(poly2)
    o3d.visualization.draw_geometries([box2, box1, polyhedron_2_trimesh(result, (0, 1, 0))], window_name="union(B1, B2)")
    print("done")

    print("poly1.intersect_with(poly2)")
    result = poly1.intersect_with(poly2)
    o3d.visualization.draw_geometries([box2, box1, polyhedron_2_trimesh(result, (0, 1, 0))], window_name="intersect(B1, B2)")
    print("done")

    print("poly1.difference_with(poly2)")
    result = poly1.difference_with(poly2)
    o3d.visualization.draw_geometries([box2, box1, polyhedron_2_trimesh(result, (0, 1, 0))], window_name="difference(B1, B2)")
    print("done")

    print("poly2.difference_with(poly1)")
    result = poly2.difference_with(poly1)
    o3d.visualization.draw_geometries([box2, box1, polyhedron_2_trimesh(result, (0, 1, 0))], window_name="difference(B2, B1)")
    print("done")


if __name__ == '__main__':
    main()