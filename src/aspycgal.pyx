# distutils: language = c++
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION

import cython
cimport numpy as np
import numpy as np
from cython.operator cimport dereference as deref, preincrement as inc
from libcpp cimport bool, nullptr

cimport wrapper

DTYPE = np.double;
ctypedef np.double_t DTYPE_t;

@cython.boundscheck(False)
cdef inline void copy_point(wrapper.Point& point, DTYPE_t[:] ptbuffer) nogil:
    ptbuffer[0] = wrapper.to_double(point.x());
    ptbuffer[1] = wrapper.to_double(point.y());
    ptbuffer[2] = wrapper.to_double(point.z());

@cython.boundscheck(False)
cdef inline void copy_vertex_point(wrapper.Vertex& vertex, DTYPE_t[:] buffer) nogil:
    copy_point(vertex.point(), buffer);


@cython.boundscheck(False)
cdef inline void copy_edge_point(wrapper.Edge& edge, DTYPE_t[:] buffer) nogil:
    copy_vertex_point(deref(edge.vertex()), buffer);


@cython.boundscheck(False)
cdef inline void copy_edge_points(wrapper.Edge& edge, DTYPE_t[:, :] buffer) nogil:
    copy_edge_point(edge, buffer[0]);
    copy_edge_point(deref(edge.opposite()), buffer[1]);


BOOL_OP_UNION = <int>wrapper.UNION;
BOOL_OP_DIFFERENCE = <int>wrapper.DIFFERENCE;
BOOL_OP_INTERSECTION = <int>wrapper.INTERSECTION;


cdef class Polyhedron:
    cdef wrapper.Polyhedron* obj;
    cdef dict _cache;

    def __init__(self):
        self.obj = new wrapper.Polyhedron();
        self._cache = {}
        if self.obj == NULL:
            raise MemoryError('Not enough memory.')

    cdef void _compute_vertices(self):
        cdef unsigned long N = 0;
        cdef unsigned long i = 0;
        cdef wrapper.Vertex* vptr;
        cdef wrapper.Vertex_iterator begin;
        cdef wrapper.Vertex_iterator end;
        cdef np.ndarray[DTYPE_t, ndim=2] result;
        cdef DTYPE_t[:, :] vresult;
        cdef dict hashmap = {};

        if self.obj is NULL:
            result = np.zeros((0, 3), DTYPE)
        else:
            i = 0;
            N = <unsigned long> (deref(self.obj).size_of_vertices());
            result = np.zeros((N, 3), DTYPE);
            vresult = result;
            begin = deref(self.obj).vertices_begin();
            end = deref(self.obj).vertices_end();
            while (begin != end) and (i < N):
                vptr = wrapper.ref_ptr[wrapper.Vertex](deref(begin));
                copy_vertex_point(deref(vptr), vresult[i]);
                hashmap[<unsigned long>vptr] = i;
                inc(i)
                inc(begin)
        
        self._cache['vertices'] = result
        self._cache['vertex_map'] = hashmap;

    cdef void _compute_edges(self):
        cdef unsigned long N = 0;
        cdef unsigned long i = 0;
        cdef wrapper.Vertex* vptr1;
        cdef wrapper.Vertex* vptr2;
        cdef wrapper.Edge_iterator begin;
        cdef wrapper.Edge_iterator end;
        cdef np.ndarray[np.uint64_t, ndim=2] result;
        cdef np.uint64_t[:, :] vresult;
        cdef dict hashmap;

        self._compute_vertices();
        hashmap = self._cache['vertex_map'];

        if self.obj is NULL:
            result = np.zeros((0, 2), np.uint64)
        else:
            N = (<unsigned long> (deref(self.obj).size_of_halfedges())) // 2;
            result = np.zeros((N, 2), np.uint64);
            vresult = result;
            begin = deref(self.obj).edges_begin();
            end = deref(self.obj).edges_end();

            while begin != end:
                vptr1 = wrapper.ref_ptr[wrapper.Vertex](deref(deref(begin).vertex()));
                vptr2 = wrapper.ref_ptr[wrapper.Vertex](deref(deref(deref(begin).opposite()).vertex()));

                vresult[i][0] = hashmap[<unsigned long>vptr1];
                vresult[i][1] = hashmap[<unsigned long>vptr2];

                inc(i)
                inc(begin)

        self._cache['edges'] = result;

    cdef void _compute_faces(self):
        cdef wrapper.Vertex* vptr;
        cdef wrapper.Facet_iterator begin;
        cdef wrapper.Facet_iterator end;
        cdef wrapper.Halfedge_around_facet_circulator fbegin;
        cdef wrapper.Halfedge_around_facet_circulator fend;
        cdef list result = [];
        cdef list facet;
        cdef dict hashmap;

        self._compute_vertices();
        hashmap = self._cache['vertex_map'];

        if self.obj is not NULL:
            begin = deref(self.obj).facets_begin();
            end = deref(self.obj).facets_end();

            while begin != end:
                fbegin = deref(begin).facet_begin();
                fend = fbegin
                if fbegin != nullptr:
                    facet = []
                    while True:
                        vptr = wrapper.ref_ptr[wrapper.Vertex](deref(deref(fbegin).vertex()));

                        facet.append(hashmap[<unsigned long>vptr]);

                        inc(fbegin)

                        if not (fbegin != fend):
                            break
                    result.append(facet);

                inc(begin)

        self._cache['faces'] = result;

    property cache:
        def __get__(self):
            return self._cache;

    property vertex_count:
        def __get__(self):
            return len(self.vertices);

    property vertices:
        @cython.boundscheck(False)
        def __get__(self):
            if 'vertices' not in self._cache:
                self._compute_vertices();

            return self._cache['vertices'];

    property edge_count:
        def __get__(self):
            return len(self.edges);

    property edges:
        def __get__(self):
            if 'edges' not in self._cache:
                self._compute_edges();

            return self._cache['edges'];

    property face_count:
        def __get__(self):
            return len(self.faces);

    property faces:
        def __get__(self):
            if 'faces' not in self._cache:
                self._compute_faces();

            return self._cache['faces'];

    def boolean_operation(self, Polyhedron other, op):
        cdef Polyhedron result = Polyhedron()
        
        if (self.obj is NULL) or (other.obj is NULL) or (result.obj is NULL):
            raise AssertionError('self.obj != NULL and other.obj != NULL and result.obj != NULL')

        wrapper.perform_boolean_operation(wrapper.to_enum[wrapper.BooleanOperation](op), self.obj, other.obj, result.obj);

        return result

    def intersect_with(self, Polyhedron other):
        return self.boolean_operation(other, BOOL_OP_INTERSECTION)

    def union_with(self, Polyhedron other):
        return self.boolean_operation(other, BOOL_OP_UNION)

    def difference_with(self, Polyhedron other):
        return self.boolean_operation(other, BOOL_OP_DIFFERENCE)

    def __mul__(self, other):
        return self.intersect_with(other)

    def __add__(self, other):
        return self.union_with(other)

    def __sub__(self, other):
        return self.difference_with(other)

    def get_volume(self):
        return wrapper.calc_volume(self.obj) if self.is_closed() else 0;

    def is_closed(self):
        return not not (self.obj and (deref(self.obj).is_closed()))

    def is_pure_bivalent(self):
        return not not (self.obj and (deref(self.obj).is_pure_bivalent()))

    def is_pure_trivalent(self):
        return not not (self.obj and (deref(self.obj).is_pure_trivalent()))

    def is_pure_triangle(self):
        return not not (self.obj and (deref(self.obj).is_pure_triangle()))

    def is_pure_quad(self):
        return not not (self.obj and (deref(self.obj).is_pure_quad()))

    def __del__(self):
        if self.obj:
            del self.obj
        self.obj = NULL

#     property some_var:
#         def __get__(self):
#             return self.cobj.some_var
#         def __set__(self, int var):
#             self.cobj.some_var = var

def Polyhedron_from_obb(obb):
    cdef np.ndarray[DTYPE_t, ndim=1] center = np.array(obb['center'], DTYPE)
    cdef np.ndarray[DTYPE_t, ndim=2] R = np.array(obb['R'], DTYPE)
    cdef np.ndarray[DTYPE_t, ndim=1] extent = np.array(obb['extent'], DTYPE)

    assert np.all(np.isfinite(center)) and np.all(np.isfinite(R)) and np.all(np.isfinite(extent))

    P = Polyhedron()
    l = R[0, :] * extent[0]
    u = R[1, :] * extent[1]
    f = R[2, :] * extent[2]

    wrapper.make_parallelepiped(
        P.obj,
        center[0], center[1], center[2],
        l[0], l[1], l[2],
        u[0], u[1], u[2],
        f[0], f[1], f[2],
    )

    return P


def Polyhedron_from_vertices_faces(vertices, faces):
    cdef np.ndarray[double] vbuf = np.array(vertices, np.double).flatten();
    cdef np.ndarray[np.uint64_t] fbuf = np.concatenate([
        np.array([len(f)] + list(f), np.uint64)
        for f in faces
    ]);

    cdef Polyhedron P = Polyhedron();

    assert np.all(np.isfinite(vertices))
    assert 0 <= min(v for f in faces for v in f)
    assert max(v for f in faces for v in f) <= len(vertices)

    print(vbuf, vbuf.dtype, len(vbuf))
    print(fbuf, fbuf.dtype, len(fbuf))

    wrapper.make_polyhedron_from_vertices_faces(
        P.obj,
        &(vbuf[0]), len(vertices),
        &(fbuf[0]), len(faces),
    );

    return P
