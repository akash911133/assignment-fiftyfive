const express = require("express");
const mongoose = require("mongoose");
const router = express.Router();

router.get("/", (req, res) => {
    // 1 = connected, 2 = connecting, 3 = disconnecting, 0 = disconnected
    const dbStatus = mongoose.connection.readyState;

    if (dbStatus === 1) {
        return res.status(200).json({
            status: "UP",
            database: "connected",
            timestamp: new Date().toISOString()
        });
    }

    // Return 503 Service Unavailable if the database is down
    return res.status(503).json({
        status: "DOWN",
        database: "disconnected",
        timestamp: new Date().toISOString()
    });
});

module.exports = router;