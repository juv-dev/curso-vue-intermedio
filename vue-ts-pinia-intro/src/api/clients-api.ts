import axios from 'axios';

const clientsApi = axios.create({
	
    baseURL: import.meta.env?.VITE_API_URL || 'http://localhost:3001',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
});

// Interceptor para manejar peticiones
clientsApi.interceptors.request.use(
    (config) => {
        if (config.method?.toUpperCase() === 'PATCH') {
            config.headers['Content-Type'] = 'application/json';
            config.headers['Accept'] = 'application/json';
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

export default clientsApi;