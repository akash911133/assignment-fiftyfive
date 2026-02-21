import axios from './axiosInstance'

export const pingServer = async () => {
  try {
    const res = await axios.get('/ping');
    console.log("Server awake:", res.data);
  } catch (err) {
    console.warn("Server ping failed:", err.message);
  }
};
