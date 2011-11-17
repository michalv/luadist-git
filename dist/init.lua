-- Luadist API

module ("dist", package.seeall)

local cfg = require "dist.config"
local git = require "dist.git"
local mf = require "dist.manifest"

-- Install package_names to deploy_dir
function install(package_names, deploy_dir)

    deploy_dir = deploy_dir or cfg.root_dir

    if type(package_names) == "string" then package_names = {package_names} end

    assert(type(package_names) == "table", "dist.install: Argument 'package_names' is not a table or string.")
    assert(type(deploy_dir) == "string", "dist.install: Argument 'deploy_dir' is not a string.")

    -- get manifest
    local manifest = mf.get_manifest()

    -- find matching packages
    local packages = find_packages(package_names, manifest)

end

-- Return specified packages from manifest
function find_packages(package_names, manifest)

    if type(package_names) == "string" then package_names = {package_names} end
    manifest = manifest or mf.get_manifest()

    assert(type(package_names) == "table", "dist.install: Argument 'package_names' is not a table or string.")
    assert(type(manifest) == "table", "dist.install: Argument 'manifest' is not a table.")

    local packages_found = {}

    -- find matching packages in manifest
    for k, pkg_to_install in pairs(package_names) do
        for k2, repo_pkg in pairs(manifest) do
            if repo_pkg.name == pkg_to_install then
                table.insert(packages_found, repo_pkg)
            end
        end
    end

    return packages_found
end

-- Return manifest consisting of packages installed in specified deploy_dir directory
function get_installed_manifest(deploy_dir)

    deploy_dir = deploy_dir or cfg.root_dir

    assert(type(deploy_dir) == "string", "dist.get_installed: Argument 'deploy_dir' is not a string.")

    local distinfos_path = deploy_dir .. "/" .. cfg.distinfos_dir
    local manifest = {}
    -- from all directories of packages installed in deploy_dir
    for dir in sys.get_directory(distinfos_path) do
        if sys.is_dir(distinfos_path .. "/" .. dir) then
            -- load the dist.info file
            for file in sys.get_directory(distinfos_path .. "/" .. dir) do
                if sys.is_file(distinfos_path .. "/" .. dir .. "/" .. file) then
                    table.insert(manifest, mf.load_distinfo(distinfos_path .. "/" .. dir .. "/" .. file))
                end
            end

        end
    end

    return manifest
end






