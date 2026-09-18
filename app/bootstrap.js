const handleEntryCompactApp = () => {
  return require('./main-dist/compact-app');
};

const setupNativeTray = () => {
  require('./native-tray').setup();
};

function bootstrap() {
  require('./libs/perf-tracing/runtime');
  perf.record(perf.STARTUP);
  require('./main-dist/migration');
  perf.record(perf.MIGRATION_DONE);
  
  const isCompactApp = process.argv.some(e => e.startsWith('--launch-compact-app'));

  if (isCompactApp) {
		if (require('electron').app.requestSingleInstanceLock()) {
			return handleEntryCompactApp();
		} else {
			require('./main-dist/second-instance');
		}
  }

  if (require('electron').app.requestSingleInstanceLock()) {
    setupNativeTray();
    perf.record(perf.MAIN_SCRIPT);
    require('./main-dist/main');
  } else {
    require('./main-dist/second-instance');
  }
}

bootstrap();
