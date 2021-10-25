#ifndef ASCGAL_WRAPPER_H
#define ASCGAL_WRAPPER_H  _

#include <cstdint>

// LICENCE: LGPL
#include <CGAL/Simple_cartesian.h>
#include <CGAL/Exact_predicates_exact_constructions_kernel.h>
#include <CGAL/Modifier_base.h>
#include <CGAL/HalfedgeDS_default.h>
#include <CGAL/Polyhedron_3.h>
#include <CGAL/Polyhedron_incremental_builder_3.h>

using std::uint64_t;

namespace AkcCGALWrap {
    typedef CGAL::Exact_predicates_exact_constructions_kernel Kernel;
    // typedef CGAL::Simple_cartesian<double> Kernel;
    typedef CGAL::Polyhedron_3<Kernel> Polyhedron;
    typedef Polyhedron::HalfedgeDS HalfedgeDS;
    typedef Polyhedron::size_type size_type;
    typedef Polyhedron::Vertex_iterator Vertex_iterator;
    typedef Polyhedron::Facet_iterator Facet_iterator;
    typedef Polyhedron::Edge_iterator Edge_iterator;
    typedef HalfedgeDS::Vertex Vertex;
    typedef Polyhedron::Facet Facet;
    typedef Facet::Halfedge_around_facet_circulator Halfedge_around_facet_circulator;
    typedef HalfedgeDS::Halfedge Halfedge;
    typedef HalfedgeDS::Halfedge Edge;
    typedef Vertex::Point Point;
    typedef Kernel::FT FT;


    template <class HDS> class Polyhedron_builder_wrapper_tpl: public CGAL::Modifier_base<HDS>{
        public:
        typedef CGAL::Polyhedron_incremental_builder_3<HDS> builder_type;

        protected:
        bool _verbose;
        builder_type* _builder;

        public:
        Polyhedron_builder_wrapper_tpl(Polyhedron* polyhedron, bool verbose=false): _verbose(verbose), _builder(0){
            polyhedron->delegate(*this);
        }
        ~Polyhedron_builder_wrapper_tpl(){
            if (_builder){
                delete _builder;
                _builder = 0;
            }
        }

        builder_type& builder(){
            return *_builder;
        }

        void operator()(HDS& hds){
            this->_builder = new builder_type(hds, _verbose);
        }
    };

    typedef Polyhedron_builder_wrapper_tpl<HalfedgeDS> Polyhedron_builder_wrapper;

    void make_parallelepiped(
        Polyhedron* P,
        double px, double py, double pz,
        double lex, double ley, double lez,
        double uex, double uey, double uez,
        double fex, double fey, double fez
    );

    void make_polyhedron_from_vertices_faces(
        Polyhedron* P,
        double* vertex_data, uint64_t num_vertices,
        uint64_t* face_data, uint64_t num_faces
    );

    enum BooleanOperation {
        UNION=1,
        DIFFERENCE=3,
        INTERSECTION=4,
    };

    template <class E> E to_enum(int v){
        return (E) v;
    }

    void perform_boolean_operation(BooleanOperation op, Polyhedron* A, Polyhedron* B, Polyhedron* C);

    double calc_volume(Polyhedron* P);

    template <class FT> double to_double(FT value){
        return CGAL::to_double(value);
    }

    template <class T> T* ref_ptr(T& obj){
        return &obj;
    }

};

#endif // ASCGAL_WRAPPER_H