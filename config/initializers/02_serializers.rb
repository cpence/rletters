# Make sure all of the serializers are loaded, so that they are registered
# with the base factory
serializer_files = File.join(Rails.root, 'lib', 'r_letters', 'documents',
                             'serializers', '*.rb')
Dir[serializer_files].each { |l| require l }
