import { useEffect, useMemo, useState } from 'react';
import {
  DataTable,
  DataTableSkeleton,
  InlineNotification,
  Pagination,
  Search,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableHeader,
  TableRow,
  Tag,
} from '@carbon/react';
import { getRoles } from '../services/api.js';

const HEADERS = [
  { key: 'title', header: 'Role' },
  { key: 'category', header: 'Category' },
  { key: 'level', header: 'Level' },
  { key: 'required', header: 'Core skills' },
];

const TAG_BY_CATEGORY = {
  Technical: 'blue',
  Sales: 'purple',
  Consulting: 'teal',
  'Product & Design': 'magenta',
  Corporate: 'gray',
};

export default function RolesPage() {
  const [roles, setRoles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [query, setQuery] = useState('');
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);

  useEffect(() => {
    getRoles()
      .then((r) => setRoles(r.roles))
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return roles;
    return roles.filter((r) => `${r.title} ${r.category} ${r.required_skills.join(' ')} ${r.preferred_skills.join(' ')}`.toLowerCase().includes(q));
  }, [roles, query]);

  const paged = filtered.slice((page - 1) * pageSize, page * pageSize);
  const rows = paged.map((r) => ({ id: r.id, title: r.title, category: r.category, level: r.level, required: r.required_skills }));

  return (
    <div className="page">
      <h1 className="page__title cds--type-productive-heading-05">Role catalog</h1>
      <p className="page__lead cds--type-body-02">
        {roles.length || 25} synthetic role profiles used for scoring. They are illustrative and are not real IBM job postings.
      </p>

      {error && <InlineNotification kind="error" hideCloseButton title="Could not load roles" subtitle={error} />}
      {loading && <DataTableSkeleton headers={HEADERS} rowCount={8} />}
      {!loading && !error && (
        <>
          <div className="role-filter">
            <Search
              size="lg"
              labelText="Search roles"
              placeholder="Search by role, category or skill"
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setPage(1);
              }}
            />
          </div>
          {filtered.length === 0 ? (
            <InlineNotification kind="info" lowContrast hideCloseButton title="No matching roles" subtitle="Try a different search term." />
          ) : (
            <DataTable rows={rows} headers={HEADERS} isSortable>
              {({ rows: tableRows, headers, getTableProps, getHeaderProps, getRowProps }) => (
                <TableContainer>
                  <Table {...getTableProps()} aria-label="IBM role catalog">
                    <TableHead>
                      <TableRow>
                        {headers.map((h) => {
                          const { key, ...rest } = getHeaderProps({ header: h });
                          return (
                            <TableHeader key={key} {...rest}>
                              {h.header}
                            </TableHeader>
                          );
                        })}
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {tableRows.map((row) => {
                        const { key, ...rest } = getRowProps({ row });
                        return (
                          <TableRow key={key} {...rest}>
                            {row.cells.map((cell) => (
                              <TableCell key={cell.id}>
                                {cell.info.header === 'category' ? (
                                  <Tag type={TAG_BY_CATEGORY[cell.value] || 'gray'} size="sm">
                                    {cell.value}
                                  </Tag>
                                ) : Array.isArray(cell.value) ? (
                                  cell.value.join(', ')
                                ) : (
                                  cell.value
                                )}
                              </TableCell>
                            ))}
                          </TableRow>
                        );
                      })}
                    </TableBody>
                  </Table>
                </TableContainer>
              )}
            </DataTable>
          )}
          <Pagination
            page={page}
            pageSize={pageSize}
            pageSizes={[10, 25]}
            totalItems={filtered.length}
            onChange={({ page: p, pageSize: ps }) => {
              setPage(p);
              setPageSize(ps);
            }}
          />
        </>
      )}
    </div>
  );
}
