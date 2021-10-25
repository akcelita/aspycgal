#include <CGAL/Nef_polyhedron_3.h>
#include <CGAL/polygon_mesh_processing.h>
#include <CGAL/boost/graph/convert_nef_polyhedron_to_polygon_mesh.h>

#include <wrapper/ascgal_wrapper.h>


#define arrayLen(arr) (sizeof(arr) / sizeof(arr[0]))

namespace AkcCGALWrap {
    typedef CGAL::Nef_polyhedron_3<Kernel> Nef_polyhedron;


    void make_polyhedron_from_vertices_faces(
        Polyhedron* P,
        double* vertex_data, uint64_t num_vertices,
        uint64_t* face_data, uint64_t num_faces
    ){
        Polyhedron_builder_wrapper pbw(P);
        Polyhedron_builder_wrapper::builder_type& B = pbw.builder();

        uint64_t num_halfedges = (num_vertices + num_faces - 2) * 2;

        B.begin_surface(num_vertices, num_halfedges, num_faces);

        for(uint64_t i=0; i < num_vertices; i++){
            double vx = *vertex_data;
            vertex_data++;
            double vy = *vertex_data;
            vertex_data++;
            double vz = *vertex_data;
            vertex_data++;

            B.add_vertex(Point(vx, vy, vz));
        }

        for(uint64_t i=0; i < num_faces; i++){
            uint64_t num_face_vertices = *face_data;
            ++face_data;
            B.begin_facet();
            for(uint64_t j=0; j < num_face_vertices; j++){
                B.add_vertex_to_facet(*face_data);
                ++face_data;
            }
            B.end_facet();
        }

        B.end_surface();
    }


    void make_parallelepiped(
        Polyhedron* P,
        double px, double py, double pz,
        double lex, double ley, double lez,
        double uex, double uey, double uez,
        double fex, double fey, double fez
    ){
        Polyhedron_builder_wrapper pbw(P);
        Polyhedron_builder_wrapper::builder_type& B = pbw.builder();

        B.begin_surface(8, 36, 12);

        int vertices[8][3] = {
            { 1,  1,  1}, {-1,  1,  1}, { 1, -1,  1}, { 1,  1, -1},
            {-1, -1, -1}, { 1, -1, -1}, {-1,  1, -1}, {-1, -1,  1},
        };
        int facets[12][3] = {
            {0, 1, 2}, {1, 7, 2},
            {0, 2, 3}, {2, 5, 3},
            {0, 3, 1}, {3, 6, 1},
            {4, 5, 7}, {5, 2, 7},
            {4, 7, 6}, {7, 1, 6},
            {4, 6, 5}, {6, 3, 5}
        };

        for(unsigned int i=0; i < arrayLen(vertices); i++){
            int* vertex = vertices[i];
            int vx = vertex[0], vy = vertex[1], vz = vertex[2];
            B.add_vertex(Point(
                px + (vx * lex + vy * ley + vz * lez) / 2,
                py + (vx * uex + vy * uey + vz * uez) / 2,
                pz + (vx * fex + vy * fey + vz * fez) / 2
            ));
        }

        for(unsigned int i=0; i < arrayLen(facets); i++){
            int* facet = facets[i];
            B.begin_facet();
            for(unsigned int j=0; j < 3; j++){
                B.add_vertex_to_facet(facet[j]);
            }
            B.end_facet();
        }

        B.end_surface();
    }


    Nef_polyhedron nef_op(BooleanOperation op, Nef_polyhedron nefA, Nef_polyhedron nefB){
        switch (op){
            case DIFFERENCE:
                return nefA - nefB;
            case INTERSECTION:
                return nefA * nefB;
            case UNION:
            default:
                return nefA + nefB;
        }
    }


    void perform_boolean_operation(BooleanOperation op, Polyhedron* A, Polyhedron* B, Polyhedron* C){
        Nef_polyhedron nefC = nef_op(op, *A, *B);
        nefC.convert_to_polyhedron(*C);
    }


    double calc_volume(Polyhedron* P){
        Kernel::FT vol = CGAL::Polygon_mesh_processing::volume(*P);
        CGAL::to_double(vol);
        return CGAL::to_double(vol);
    }

};
