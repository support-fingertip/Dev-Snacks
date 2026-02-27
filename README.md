# Dev-Snacks
This is the development repo of Dev Snacks (Seraphine Impex Pvt. Ltd.)

Salesforce DX Project - API Version 59.0

## 🚀 Getting Started

1. **Authorize your org**
   ```bash
   sf org login web --alias myorg --set-default
   ```

2. **Deploy to your org**
   ```bash
   sf project deploy start --source-dir force-app --target-org myorg
   ```

3. **Run tests**
   ```bash
   sf apex run test --target-org myorg --test-level RunLocalTests
   ```

## 📁 Project Structure

- `force-app/` - Main source directory
- `scripts/` - Utility scripts
- `config/` - Configuration files

## 🛠️ Development
