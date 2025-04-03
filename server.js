const app = require('./app');
const PORT = process.env.PORT || 4000;

// 🔽 Route logger function
function listRoutes() {
  console.log('Registered routes:');
  app._router.stack.forEach((middleware) => {
    if (middleware.route) {
      const methods = Object.keys(middleware.route.methods)
        .map((method) => method.toUpperCase())
        .join(', ');
      console.log(`${methods} ${middleware.route.path}`);
    }
  });
}

// ✅ Log all registered routes
listRoutes();

// ✅ Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
