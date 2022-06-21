if get_option('enable_examples')

  example_deps = libforem_deps + [ libforem_dep ]

  executable('hello-forem', 'hello-forem.vala',
    dependencies: example_deps,
    vala_args: [
        '--pkg=posix',
        '--vapidir=' + meson.source_root() + '/vapi'
        ],
    install: false
  )

endif
