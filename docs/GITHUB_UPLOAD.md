# GitHub Upload Checklist

Use this checklist when you are ready to push the project to GitHub.

## 1. Check Ignored Files

Git LFS is configured for large Unity media files. Make sure it is enabled before the first commit:

```bash
git lfs install
```

```bash
git status --ignored
```

Expected ignored folders include Unity `Library`, Unity `Logs`, PlatformIO `.pio`, Flutter `build`, Flutter `.dart_tool`, and local secret config files.

## 2. Commit

```bash
git add .
git status --short
git commit -m "Initial GitHub-ready project"
```

## 3. Connect GitHub Remote

Create a GitHub repository, then run:

```bash
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

## 4. Public Repository Warning

If the repository will be public, confirm third-party asset redistribution rights first. If you are unsure about any Unity asset folder, make the repository private.
