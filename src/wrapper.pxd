# distutils: language = c++

from libcpp cimport bool, nullptr_t


cdef extern from "<wrapper/ascgal_wrapper.h>" namespace "AkcCGALWrap":
    cppclass FT:
        pass

    cppclass size_type:
        pass

    cppclass Point:
        FT x() nogil const;
        FT y() nogil const;
        FT z() nogil const;

    cppclass Vertex:
        Point point() nogil;

    cppclass Halfedge:
        Halfedge* opposite() nogil;
        Halfedge* next() nogil;
        Vertex* vertex() nogil;

    cppclass Edge:
        Edge* opposite() nogil;
        Edge* next() nogil;
        Vertex* vertex() nogil;

    cppclass Halfedge_around_facet_circulator:
        Halfedge operator*();
        int operator!=(Halfedge_around_facet_circulator o);
        int operator!=(nullptr_t o);
        Halfedge_around_facet_circulator operator++();

    cppclass Facet:
        Edge* halfedge() nogil;
        size_t facet_degree() nogil;
        bool is_triangle() nogil;
        bool is_quad() nogil;
        Halfedge_around_facet_circulator facet_begin() nogil;

    cppclass Vertex_iterator:
        Vertex operator*();
        int operator!=(Vertex_iterator o);
        Vertex_iterator operator++();
        
    cppclass Edge_iterator:
        Edge operator*();
        int operator!=(Edge_iterator o);
        Edge_iterator operator++();

    cppclass Facet_iterator:
        Facet operator*();
        int operator!=(Facet_iterator o);
        Facet_iterator operator++();

    cppclass Polyhedron:
        size_type size_of_facets() nogil ;
        size_type size_of_vertices() nogil ;
        size_type size_of_halfedges() nogil ;
        Vertex_iterator vertices_begin() nogil ;
        Vertex_iterator vertices_end() nogil ;
        Edge_iterator edges_begin() nogil ;
        Edge_iterator edges_end() nogil ;
        Facet_iterator facets_begin() nogil ;
        Facet_iterator facets_end() nogil ;
        bool is_closed () nogil const;
        bool is_pure_bivalent () nogil const;
        bool is_pure_trivalent () nogil const;
        bool is_pure_triangle () nogil const;
        bool is_pure_quad () nogil const;
        
    void make_parallelepiped(
        Polyhedron* P,
        double px, double py, double pz,
        double lex, double ley, double lez,
        double uex, double uey, double uez,
        double fex, double fey, double fez
    );

    void make_polyhedron_from_vertices_faces(
        Polyhedron* P,
        double* vertex_data, unsigned int num_vertices,
        unsigned int* face_data, unsigned int num_faces
    );

    cppclass BooleanOperation:
        pass

    E to_enum[E](int v);

    BooleanOperation UNION;
    BooleanOperation DIFFERENCE;
    BooleanOperation INTERSECTION;

    void perform_boolean_operation(BooleanOperation op, Polyhedron* A, Polyhedron* B, Polyhedron* C) except +;

    double calc_volume(Polyhedron* P) except +;
    double to_double[FT](FT value) nogil;

    T* ref_ptr[T](T& obj);
