if get_option('shared_lib')
  libtype = 'shared_library'
else
  libtype = 'static_library'
endif

libforem_sources = [
  'Forem.vala'
]


confh = configuration_data ()
confh.set_quoted('PACKAGE_LOCALE_DIR', join_paths(get_option('prefix'), get_option('datadir'), 'locale'))
confh.set_quoted('GETTEXT_PACKAGE', 'forem')
confh.set_quoted('VERSION', meson.project_version())
configure_file(output : 'config.h',
  configuration : confh)

inc_libh = include_directories ('.')
inc_libh_dep = declare_dependency (include_directories : inc_libh)

libforem = build_target('forem',
    sources: libforem_sources,
    dependencies: libforem_deps,
    vala_args: [
        '--pkg=posix',
        '--vapidir=' + meson.source_root() + '/vapi'
        ],
    target_type: libtype,
    vala_header: 'forem.h',
    vala_vapi: 'forem.vapi',
    c_args: [ '-include', meson.current_build_dir() + '/config.h', '-w'],
    install_dir: [true, true, true],
    install: true,
)

libforem_dep = declare_dependency(
  include_directories: include_directories('.'),
            link_with: libforem,
)

pkg = import('pkgconfig')
pkg.generate(
    libraries: libforem,
      version: meson.project_version(),
         name: 'forem',
  description: 'Publish to Forem communities',
)
