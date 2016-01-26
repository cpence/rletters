
namespace :npm do
  desc 'Install the NPM modules required for RLetters'
  task :install do
    system('npm install', chdir: 'vendor/assets')
  end

  desc 'Show outdated NPM modules'
  task :outdated do
    system('npm outdated', chdir: 'vendor/assets')
  end

  desc 'Update all of the NPM modules'
  task :update do
    Dir.chdir('vendor/assets') do
      File.unlink('npm-shrinkwrap.json')
      system('npm update')
      system('npm prune')
      system('npm shrinkwrap')
    end
  end
end
