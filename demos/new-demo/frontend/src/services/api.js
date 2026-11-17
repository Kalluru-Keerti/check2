import axios from 'axios';

// Thin wrapper over the FastAPI backend. Throws Error(message) with the server's detail text.
const base = import.meta.env.VITE_API_BASE_URL || '/api';
const http = axios.create({ baseURL: base, timeout: 60000 });

http.interceptors.response.use(
  (r) => r.data,
  (err) => {
    const detail = err.response?.data?.detail;
    const message = typeof detail === 'string' ? detail : err.message || 'Request failed';
    return Promise.reject(new Error(message));
  }
);

export const getHealth = () => http.get('/health');
export const getCategories = () => http.get('/data/categories');
export const getRoles = (category) => http.get('/data/roles', { params: category ? { category } : {} });
export const getSamples = () => http.get('/data/samples');

/** Analyse a resume: pass either {file} (any format) or {sampleId}. */
export function analyzeResume({ roleId, file, sampleId }) {
  const form = new FormData();
  form.append('role_id', roleId);
  if (sampleId) form.append('sample_id', sampleId);
  else if (file) form.append('file', file);
  return http.post('/ai/analyze', form);
}
