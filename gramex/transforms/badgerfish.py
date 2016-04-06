import yaml
import xmljson
import lxml.html
import tornado.gen
from orderedattrdict.yamlutils import AttrDictYAMLLoader
from . import build_transform
from ..config import walk, load_imports


@tornado.gen.coroutine
def badgerfish(content, handler=None, mapping={}, doctype='<!DOCTYPE html>'):
    '''
    A transform that converts string content to YAML, then maps nodes
    using other functions, and renders the output as HTML.

    The specs for this function are in progress.
    '''
    data = yaml.load(content, Loader=AttrDictYAMLLoader)
    if handler is not None and hasattr(handler, 'file'):
        load_imports(data, handler.file)
    maps = {tag: build_transform(trans) for tag, trans in mapping.items()}
    for tag, value, node in walk(data):
        if tag in maps:
            node[tag] = yield maps[tag](value)
    raise tornado.gen.Return(lxml.html.tostring(xmljson.badgerfish.etree(data)[0],
                                                doctype=doctype, encoding='unicode'))