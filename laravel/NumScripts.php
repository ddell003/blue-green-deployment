<?php
// place in app/Console/Commands/Dev
namespace App\Console\Commands\Dev;

use App;
use App\Services\Account\AccountService;
use App\Services\Template\TemplateService;
use App\Services\Template\TemplateTypes;
use App\TenantManager;
use Illuminate\Console\Command;
use Illuminate\Validation\Rule;
use Laravel\Passport\Passport;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class NumScripts extends Command
{
    /**
     * The name and signature of the console command.
     * @var string
     */
    protected $signature = 'dev:num-scripts';

    /**
     * The console command description.
     * @var string
     */
    protected $description = <<<TEXT
Computes the amount of php scripts currently in the application.
This is useful for knowing what to set the opcache "max_accelerated_files" config.
TEXT;

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        if ( ! $root = $this->getRoot()) {
            $this->line('Laravel root could not be found.');
            return 1;
        }

        exec("cd {$root}");
        exec("find . -name '*.php' -type f -print | wc -l", $output);

        $files = array_pop($output);

        $this->line('Total Files in Project');
        $this->line(trim($files));
    }

    private function getRoot()
    {
        return base_path();
    }

}
